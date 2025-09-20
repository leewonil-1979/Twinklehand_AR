// CameraScreen.js - 메인 화면
import React, { useEffect, useRef, useState, useCallback } from 'react';
import HandTrackingService from '../services/HandTrackingService';
import ParticleSystem from '../components/ParticleSystem';

/**
 * 메인 카메라 화면 컴포넌트
 * MediaPipe 손 추적과 AR 효과를 결합한 메인 인터페이스
 */
const CameraScreen = () => {
  // Refs
  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const containerRef = useRef(null);
  const animationFrameRef = useRef(null);
  
  // State
  const [isInitialized, setIsInitialized] = useState(false);
  const [isTracking, setIsTracking] = useState(false);
  const [hands, setHands] = useState([]);
  const [currentMode, setCurrentMode] = useState('clean'); // 'clean' | 'dirty'
  const [selectedEffect, setSelectedEffect] = useState('✨');
  const [error, setError] = useState(null);
  const [cameraPermission, setCameraPermission] = useState('pending');
  const [videoSize, setVideoSize] = useState({ width: 0, height: 0 });
  
  // 이펙트 옵션
  const effects = {
    clean: ['✨', '🌟', '💎', '🦋', '🌸', '❄️', '💫', '🎭'],
    dirty: ['🦠', '🧼', '💧', '🫧', '🚿', '🧽', '🔧', '⚡']
  };

  /**
   * 컴포넌트 초기화
   */
  useEffect(() => {
    initializeApp();
    
    return () => {
      cleanup();
    };
  }, []);

  /**
   * 앱 초기화 프로세스
   */
  const initializeApp = async () => {
    try {
      console.log('📱 CameraScreen 초기화 시작...');
      
      // 카메라 권한 요청
      await requestCameraPermission();
      
      // MediaPipe 초기화
      await initializeMediaPipe();
      
      // 카메라 스트림 시작
      await startCamera();
      
      setIsInitialized(true);
      console.log('✅ CameraScreen 초기화 완료!');
      
    } catch (error) {
      console.error('❌ 앱 초기화 실패:', error);
      setError(`초기화 실패: ${error.message}`);
    }
  };

  /**
   * 카메라 권한 요청
   */
  const requestCameraPermission = async () => {
    try {
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        throw new Error('이 브라우저는 카메라를 지원하지 않습니다.');
      }
      
      setCameraPermission('requesting');
      
      // 권한 테스트용 임시 스트림
      const testStream = await navigator.mediaDevices.getUserMedia({ 
        video: true 
      });
      testStream.getTracks().forEach(track => track.stop());
      
      setCameraPermission('granted');
      console.log('✅ 카메라 권한 허용됨');
      
    } catch (error) {
      setCameraPermission('denied');
      throw new Error('카메라 권한이 필요합니다.');
    }
  };

  /**
   * MediaPipe 초기화
   */
  const initializeMediaPipe = async () => {
    try {
      // 콜백 함수 설정
      HandTrackingService.setCallbacks(
        handleHandsDetected,
        handleNoHandsDetected,
        handleTrackingError
      );
      
      // MediaPipe 초기화
      await HandTrackingService.initialize();
      
      console.log('✅ MediaPipe 초기화 완료');
      
    } catch (error) {
      throw new Error(`MediaPipe 초기화 실패: ${error.message}`);
    }
  };

  /**
   * 카메라 스트림 시작
   */
  const startCamera = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          width: { ideal: 1280 },
          height: { ideal: 720 },
          facingMode: 'user' // 전면 카메라
        }
      });
      
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        videoRef.current.addEventListener('loadedmetadata', handleVideoLoaded);
        videoRef.current.play();
      }
      
    } catch (error) {
      throw new Error(`카메라 시작 실패: ${error.message}`);
    }
  };

  /**
   * 비디오 로드 완료 처리
   */
  const handleVideoLoaded = useCallback(() => {
    const video = videoRef.current;
    if (!video) return;
    
    const { videoWidth, videoHeight } = video;
    setVideoSize({ width: videoWidth, height: videoHeight });
    
    // 캔버스 크기 설정
    if (canvasRef.current) {
      canvasRef.current.width = videoWidth;
      canvasRef.current.height = videoHeight;
    }
    
    // 손 추적 시작
    startHandTracking();
    
    console.log(`📹 비디오 로드 완료: ${videoWidth}x${videoHeight}`);
  }, []);

  /**
   * 손 추적 시작
   */
  const startHandTracking = () => {
    if (!isTracking) {
      HandTrackingService.startTracking();
      setIsTracking(true);
      
      // 애니메이션 프레임 시작
      animationFrameRef.current = requestAnimationFrame(processFrame);
      
      console.log('🎯 손 추적 시작됨');
    }
  };

  /**
   * 손 추적 중지
   */
  const stopHandTracking = () => {
    if (isTracking) {
      HandTrackingService.stopTracking();
      setIsTracking(false);
      
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
        animationFrameRef.current = null;
      }
      
      console.log('⏹️ 손 추적 중지됨');
    }
  };

  /**
   * 프레임 처리 (메인 루프)
   */
  const processFrame = useCallback(() => {
    const video = videoRef.current;
    
    if (video && video.readyState >= 2 && isTracking) {
      const currentTime = video.currentTime * 1000; // milliseconds
      HandTrackingService.detectHands(video, currentTime);
    }
    
    if (isTracking) {
      animationFrameRef.current = requestAnimationFrame(processFrame);
    }
  }, [isTracking]);

  /**
   * 손 감지 콜백
   */
  const handleHandsDetected = useCallback((detectedHands) => {
    setHands(detectedHands);
    
    // 손의 청결도에 따라 모드 자동 변경
    const hasCleanHand = detectedHands.some(hand => hand.isClean);
    const newMode = hasCleanHand ? 'clean' : 'dirty';
    
    if (newMode !== currentMode) {
      setCurrentMode(newMode);
      console.log(`🔄 모드 변경: ${newMode}`);
    }
  }, [currentMode]);

  /**
   * 손 미감지 콜백
   */
  const handleNoHandsDetected = useCallback(() => {
    setHands([]);
  }, []);

  /**
   * 추적 에러 콜백
   */
  const handleTrackingError = useCallback((errorType, message) => {
    console.error(`추적 에러 [${errorType}]:`, message);
    setError(`추적 오류: ${message}`);
  }, []);

  /**
   * 모드 토글
   */
  const toggleMode = () => {
    const newMode = currentMode === 'clean' ? 'dirty' : 'clean';
    setCurrentMode(newMode);
    console.log(`🔄 수동 모드 변경: ${newMode}`);
  };

  /**
   * 이펙트 선택
   */
  const selectEffect = (effect) => {
    setSelectedEffect(effect);
    console.log(`✨ 이펙트 선택: ${effect}`);
  };

  /**
   * 사진 캡처
   */
  const capturePhoto = () => {
    const video = videoRef.current;
    const canvas = canvasRef.current;
    
    if (!video || !canvas) return;
    
    try {
      const ctx = canvas.getContext('2d');
      
      // 비디오 프레임 캡처
      ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
      
      // 현재 손 위치에 파티클 효과 그리기
      if (hands.length > 0) {
        hands.forEach(hand => {
          hand.landmarks.forEach(landmark => {
            const x = landmark.x * canvas.width;
            const y = landmark.y * canvas.height;
            
            // 이펙트 그리기
            ctx.font = '30px Arial';
            ctx.textAlign = 'center';
            ctx.fillText(selectedEffect, x, y);
          });
        });
      }
      
      // 이미지 다운로드
      const link = document.createElement('a');
      link.download = `twinkle-hands-${Date.now()}.png`;
      link.href = canvas.toDataURL();
      link.click();
      
      console.log('📸 사진 캡처 완료');
      
    } catch (error) {
      console.error('사진 캡처 실패:', error);
      setError('사진 캡처에 실패했습니다.');
    }
  };

  /**
   * 리소스 정리
   */
  const cleanup = () => {
    stopHandTracking();
    
    // 비디오 스트림 정리
    if (videoRef.current && videoRef.current.srcObject) {
      const stream = videoRef.current.srcObject;
      stream.getTracks().forEach(track => track.stop());
    }
    
    // MediaPipe 정리
    HandTrackingService.dispose();
    
    console.log('🗑️ CameraScreen 리소스 정리 완료');
  };

  /**
   * 에러 화면 렌더링
   */
  if (error) {
    return (
      <div style={styles.errorContainer}>
        <div style={styles.errorContent}>
          <h2>❌ 오류 발생</h2>
          <p>{error}</p>
          <button 
            style={styles.retryButton}
            onClick={() => {
              setError(null);
              initializeApp();
            }}
          >
            다시 시도
          </button>
        </div>
      </div>
    );
  }

  /**
   * 로딩 화면 렌더링
   */
  if (!isInitialized) {
    return (
      <div style={styles.loadingContainer}>
        <div style={styles.loadingContent}>
          <div style={styles.spinner}></div>
          <h2>🚀 TwinkleHands AR</h2>
          <p>카메라와 MediaPipe를 초기화하는 중...</p>
          <div style={styles.progressSteps}>
            <div className={cameraPermission !== 'pending' ? 'completed' : ''}>
              📹 카메라 권한 확인
            </div>
            <div className={isInitialized ? 'completed' : ''}>
              🤖 AI 손 추적 초기화
            </div>
            <div className={isTracking ? 'completed' : ''}>
              ✨ AR 효과 준비
            </div>
          </div>
        </div>
      </div>
    );
  }

  /**
   * 메인 화면 렌더링
   */
  return (
    <div style={styles.container} ref={containerRef}>
      {/* 비디오 레이어 */}
      <video
        ref={videoRef}
        style={styles.video}
        playsInline
        muted
        autoPlay
      />
      
      {/* AR 효과 레이어 */}
      <ParticleSystem
        hands={hands}
        effect={selectedEffect}
        mode={currentMode}
        videoSize={videoSize}
        style={styles.particleLayer}
      />
      
      {/* 디버그 캔버스 (개발용) */}
      <canvas
        ref={canvasRef}
        style={{ ...styles.debugCanvas, display: 'none' }}
      />
      
      {/* UI 컨트롤 레이어 */}
      <div style={styles.uiLayer}>
        {/* 상단 상태 표시 */}
        <div style={styles.statusBar}>
          <div style={styles.modeIndicator}>
            <span style={{
              ...styles.modeIcon,
              backgroundColor: currentMode === 'clean' ? '#4CAF50' : '#FF5722'
            }}>
              {currentMode === 'clean' ? '✨' : '🦠'}
            </span>
            <span style={styles.modeText}>
              {currentMode === 'clean' ? '깨끗함' : '더러움'}
            </span>
          </div>
          
          <div style={styles.handCount}>
            {hands.length > 0 ? `👋 ${hands.length}개 손 인식` : '🚫 손 없음'}
          </div>
        </div>
        
        {/* 이펙트 선택 바 */}
        <div style={styles.effectsBar}>
          {effects[currentMode].map(effect => (
            <button
              key={effect}
              style={{
                ...styles.effectButton,
                backgroundColor: selectedEffect === effect ? '#2196F3' : 'transparent'
              }}
              onClick={() => selectEffect(effect)}
            >
              {effect}
            </button>
          ))}
        </div>
        
        {/* 하단 컨트롤 */}
        <div style={styles.bottomControls}>
          <button
            style={styles.modeToggleButton}
            onClick={toggleMode}
          >
            🔄 모드 변경
          </button>
          
          <button
            style={styles.captureButton}
            onClick={capturePhoto}
          >
            📸 촬영
          </button>
          
          <button
            style={styles.trackingToggleButton}
            onClick={isTracking ? stopHandTracking : startHandTracking}
          >
            {isTracking ? '⏹️ 정지' : '▶️ 시작'}
          </button>
        </div>
      </div>
      
      {/* 손 정보 표시 (개발용) */}
      {hands.length > 0 && (
        <div style={styles.handInfo}>
          {hands.map((hand, index) => (
            <div key={index} style={styles.handDetail}>
              <strong>{hand.handedness}</strong>: {hand.gesture} 
              ({hand.isClean ? 'Clean' : 'Dirty'})
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

/**
 * 스타일 정의
 */
const styles = {
  container: {
    position: 'relative',
    width: '100vw',
    height: '100vh',
    overflow: 'hidden',
    backgroundColor: '#000'
  },
  video: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
    objectFit: 'cover',
    transform: 'scaleX(-1)' // 거울 효과
  },
  particleLayer: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
    pointerEvents: 'none',
    zIndex: 2
  },
  debugCanvas: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
    pointerEvents: 'none',
    zIndex: 3
  },
  uiLayer: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
    pointerEvents: 'none',
    zIndex: 10
  },
  statusBar: {
    position: 'absolute',
    top: 20,
    left: 20,
    right: 20,
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    pointerEvents: 'auto'
  },
  modeIndicator: {
    display: 'flex',
    alignItems: 'center',
    background: 'rgba(0,0,0,0.7)',
    borderRadius: 20,
    padding: '8px 16px',
    color: 'white'
  },
  modeIcon: {
    width: 20,
    height: 20,
    borderRadius: 10,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 8,
    fontSize: 12
  },
  modeText: {
    fontSize: 14,
    fontWeight: 'bold'
  },
  handCount: {
    background: 'rgba(0,0,0,0.7)',
    borderRadius: 20,
    padding: '8px 16px',
    color: 'white',
    fontSize: 14
  },
  effectsBar: {
    position: 'absolute',
    top: 80,
    left: 20,
    right: 20,
    display: 'flex',
    justifyContent: 'center',
    gap: 10,
    pointerEvents: 'auto'
  },
  effectButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    border: '2px solid rgba(255,255,255,0.5)',
    background: 'rgba(0,0,0,0.5)',
    color: 'white',
    fontSize: 20,
    cursor: 'pointer',
    transition: 'all 0.3s ease'
  },
  bottomControls: {
    position: 'absolute',
    bottom: 40,
    left: 20,
    right: 20,
    display: 'flex',
    justifyContent: 'center',
    gap: 20,
    pointerEvents: 'auto'
  },
  modeToggleButton: {
    padding: '12px 24px',
    borderRadius: 25,
    border: 'none',
    background: 'rgba(0,0,0,0.7)',
    color: 'white',
    fontSize: 14,
    cursor: 'pointer'
  },
  captureButton: {
    width: 80,
    height: 80,
    borderRadius: 40,
    border: '4px solid white',
    background: '#FF5722',
    color: 'white',
    fontSize: 24,
    cursor: 'pointer',
    boxShadow: '0 4px 20px rgba(0,0,0,0.3)'
  },
  trackingToggleButton: {
    padding: '12px 24px',
    borderRadius: 25,
    border: 'none',
    background: 'rgba(0,0,0,0.7)',
    color: 'white',
    fontSize: 14,
    cursor: 'pointer'
  },
  handInfo: {
    position: 'absolute',
    bottom: 120,
    left: 20,
    background: 'rgba(0,0,0,0.8)',
    borderRadius: 10,
    padding: 10,
    color: 'white',
    fontSize: 12,
    pointerEvents: 'none'
  },
  handDetail: {
    marginBottom: 5
  },
  loadingContainer: {
    width: '100vw',
    height: '100vh',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    color: 'white'
  },
  loadingContent: {
    textAlign: 'center',
    maxWidth: 400,
    padding: 40
  },
  spinner: {
    width: 60,
    height: 60,
    border: '4px solid rgba(255,255,255,0.3)',
    borderTop: '4px solid white',
    borderRadius: '50%',
    animation: 'spin 1s linear infinite',
    margin: '0 auto 20px'
  },
  progressSteps: {
    marginTop: 30,
    textAlign: 'left'
  },
  errorContainer: {
    width: '100vw',
    height: '100vh',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    background: '#f44336',
    color: 'white'
  },
  errorContent: {
    textAlign: 'center',
    maxWidth: 400,
    padding: 40
  },
  retryButton: {
    padding: '12px 24px',
    marginTop: 20,
    borderRadius: 25,
    border: 'none',
    background: 'white',
    color: '#f44336',
    fontSize: 16,
    cursor: 'pointer',
    fontWeight: 'bold'
  }
};

export default CameraScreen;