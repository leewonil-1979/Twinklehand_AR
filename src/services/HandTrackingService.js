// HandTrackingService.js - MediaPipe 서비스
import { 
  HandLandmarker, 
  FilesetResolver,
  DrawingUtils 
} from '@mediapipe/tasks-vision';

/**
 * MediaPipe 기반 실시간 손 추적 서비스
 * 웹 환경에서 손 인식 및 랜드마크 추출
 */
class HandTrackingService {
  constructor() {
    this.handLandmarker = null;
    this.isInitialized = false;
    this.isTracking = false;
    this.lastVideoTime = -1;
    
    // 콜백 함수들
    this.onHandsDetected = null;
    this.onNoHandsDetected = null;
    this.onError = null;
    
    // 설정값
    this.config = {
      baseOptions: {
        modelAssetPath: 'https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task',
        delegate: 'GPU'
      },
      runningMode: 'VIDEO',
      numHands: 2,
      minHandDetectionConfidence: 0.7,
      minHandPresenceConfidence: 0.5,
      minTrackingConfidence: 0.5
    };
  }

  /**
   * MediaPipe 초기화
   */
  async initialize() {
    try {
      console.log('🚀 HandTrackingService 초기화 시작...');
      
      // FilesetResolver로 WASM 파일들 로드
      const vision = await FilesetResolver.forVisionTasks(
        'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.0/wasm'
      );

      // HandLandmarker 생성
      this.handLandmarker = await HandLandmarker.createFromOptions(vision, {
        baseOptions: this.config.baseOptions,
        runningMode: this.config.runningMode,
        numHands: this.config.numHands,
        minHandDetectionConfidence: this.config.minHandDetectionConfidence,
        minHandPresenceConfidence: this.config.minHandPresenceConfidence,
        minTrackingConfidence: this.config.minTrackingConfidence
      });

      this.isInitialized = true;
      console.log('✅ HandTrackingService 초기화 완료!');
      return true;
      
    } catch (error) {
      console.error('❌ HandTrackingService 초기화 실패:', error);
      if (this.onError) {
        this.onError('INIT_ERROR', error.message);
      }
      throw error;
    }
  }

  /**
   * 손 추적 시작
   */
  startTracking() {
    if (!this.isInitialized) {
      throw new Error('HandTrackingService가 초기화되지 않았습니다.');
    }
    
    this.isTracking = true;
    console.log('🎯 손 추적 시작');
  }

  /**
   * 손 추적 중지
   */
  stopTracking() {
    this.isTracking = false;
    console.log('⏹️ 손 추적 중지');
  }

  /**
   * 비디오 프레임에서 손 감지
   * @param {HTMLVideoElement} video - 비디오 엘리먼트
   * @param {number} timestamp - 프레임 타임스탬프
   */
  detectHands(video, timestamp) {
    if (!this.isInitialized || !this.isTracking || !this.handLandmarker) {
      return;
    }

    // 동일한 프레임 중복 처리 방지
    if (timestamp === this.lastVideoTime) {
      return;
    }
    this.lastVideoTime = timestamp;

    try {
      // MediaPipe로 손 감지 실행
      const results = this.handLandmarker.detectForVideo(video, timestamp);
      
      if (results.landmarks && results.landmarks.length > 0) {
        // 손이 감지됨
        const handsData = this.processHandResults(results);
        
        if (this.onHandsDetected) {
          this.onHandsDetected(handsData);
        }
      } else {
        // 손이 감지되지 않음
        if (this.onNoHandsDetected) {
          this.onNoHandsDetected();
        }
      }
      
    } catch (error) {
      console.error('손 감지 중 오류:', error);
      if (this.onError) {
        this.onError('DETECTION_ERROR', error.message);
      }
    }
  }

  /**
   * MediaPipe 결과를 앱에서 사용할 형태로 변환
   * @param {Object} results - MediaPipe 결과
   * @returns {Array} 처리된 손 데이터 배열
   */
  processHandResults(results) {
    const hands = [];
    
    for (let i = 0; i < results.landmarks.length; i++) {
      const landmarks = results.landmarks[i];
      const handedness = results.handednesses[i];
      const worldLandmarks = results.worldLandmarks[i];
      
      // 손 정보 구성
      const handData = {
        id: i,
        handedness: handedness[0].categoryName, // 'Left' or 'Right'
        confidence: handedness[0].score,
        landmarks: landmarks.map(landmark => ({
          x: landmark.x,
          y: landmark.y,
          z: landmark.z || 0
        })),
        worldLandmarks: worldLandmarks.map(landmark => ({
          x: landmark.x,
          y: landmark.y,
          z: landmark.z
        })),
        // 주요 포인트 추출
        keyPoints: this.extractKeyPoints(landmarks),
        // 제스처 분석
        gesture: this.analyzeGesture(landmarks),
        // 손 상태
        isClean: this.analyzeHandCleanliness(landmarks)
      };
      
      hands.push(handData);
    }
    
    return hands;
  }

  /**
   * 주요 손 포인트 추출 (엄지, 검지 등)
   * @param {Array} landmarks - 손 랜드마크 배열
   * @returns {Object} 주요 포인트들
   */
  extractKeyPoints(landmarks) {
    return {
      // 손목
      wrist: landmarks[0],
      // 엄지
      thumb: {
        tip: landmarks[4],
        ip: landmarks[3],
        mcp: landmarks[2],
        cmc: landmarks[1]
      },
      // 검지
      index: {
        tip: landmarks[8],
        dip: landmarks[7],
        pip: landmarks[6],
        mcp: landmarks[5]
      },
      // 중지
      middle: {
        tip: landmarks[12],
        dip: landmarks[11],
        pip: landmarks[10],
        mcp: landmarks[9]
      },
      // 약지
      ring: {
        tip: landmarks[16],
        dip: landmarks[15],
        pip: landmarks[14],
        mcp: landmarks[13]
      },
      // 소지
      pinky: {
        tip: landmarks[20],
        dip: landmarks[19],
        pip: landmarks[18],
        mcp: landmarks[17]
      },
      // 손바닥 중심
      palm: landmarks[0] // 손목을 기준으로 사용
    };
  }

  /**
   * 제스처 분석 (손 모양 인식)
   * @param {Array} landmarks - 손 랜드마크 배열
   * @returns {string} 감지된 제스처
   */
  analyzeGesture(landmarks) {
    const keyPoints = this.extractKeyPoints(landmarks);
    
    // 각 손가락이 펴져있는지 확인
    const fingersUp = {
      thumb: keyPoints.thumb.tip.x > keyPoints.thumb.ip.x, // 엄지는 x축 기준
      index: keyPoints.index.tip.y < keyPoints.index.pip.y,
      middle: keyPoints.middle.tip.y < keyPoints.middle.pip.y,
      ring: keyPoints.ring.tip.y < keyPoints.ring.pip.y,
      pinky: keyPoints.pinky.tip.y < keyPoints.pinky.pip.y
    };
    
    const upCount = Object.values(fingersUp).filter(Boolean).length;
    
    // 제스처 분류
    if (upCount === 0) return 'fist';
    if (upCount === 1 && fingersUp.index) return 'point';
    if (upCount === 2 && fingersUp.index && fingersUp.middle) return 'peace';
    if (upCount === 5) return 'open';
    if (fingersUp.thumb && fingersUp.pinky && upCount === 2) return 'hang_loose';
    
    return 'unknown';
  }

  /**
   * 손의 청결도 분석 (AI 기반 가상 분석)
   * @param {Array} landmarks - 손 랜드마크 배열
   * @returns {boolean} 청결한지 여부
   */
  analyzeHandCleanliness(landmarks) {
    // 실제로는 컴퓨터 비전이나 AI 모델이 필요하지만,
    // 데모를 위해 손의 움직임 패턴으로 판단
    const keyPoints = this.extractKeyPoints(landmarks);
    
    // 손의 펼쳐진 정도로 판단 (펼쳐진 손 = 깨끗함으로 가정)
    const gesture = this.analyzeGesture(landmarks);
    const isOpenGesture = gesture === 'open' || gesture === 'peace';
    
    // 손목과 손가락 끝의 거리로 손의 펼쳐진 정도 계산
    const wrist = keyPoints.wrist;
    const fingertips = [
      keyPoints.thumb.tip,
      keyPoints.index.tip,
      keyPoints.middle.tip,
      keyPoints.ring.tip,
      keyPoints.pinky.tip
    ];
    
    const avgDistance = fingertips.reduce((sum, tip) => {
      const distance = Math.sqrt(
        Math.pow(tip.x - wrist.x, 2) + Math.pow(tip.y - wrist.y, 2)
      );
      return sum + distance;
    }, 0) / fingertips.length;
    
    // 거리가 클수록 손이 펼쳐져 있음 = 깨끗함
    return isOpenGesture && avgDistance > 0.15;
  }

  /**
   * 설정 업데이트
   * @param {Object} newConfig - 새로운 설정
   */
  updateConfig(newConfig) {
    this.config = { ...this.config, ...newConfig };
    console.log('⚙️ HandTrackingService 설정 업데이트:', this.config);
  }

  /**
   * 콜백 함수 등록
   * @param {Function} onHandsDetected - 손 감지 콜백
   * @param {Function} onNoHandsDetected - 손 미감지 콜백
   * @param {Function} onError - 에러 콜백
   */
  setCallbacks(onHandsDetected, onNoHandsDetected, onError) {
    this.onHandsDetected = onHandsDetected;
    this.onNoHandsDetected = onNoHandsDetected;
    this.onError = onError;
  }

  /**
   * 리소스 정리
   */
  dispose() {
    this.stopTracking();
    
    if (this.handLandmarker) {
      this.handLandmarker.close();
      this.handLandmarker = null;
    }
    
    this.isInitialized = false;
    console.log('🗑️ HandTrackingService 리소스 정리 완료');
  }
}

// 싱글톤 인스턴스 export
export default new HandTrackingService();