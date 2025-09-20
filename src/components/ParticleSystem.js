// ParticleSystem.js - 파티클 효과
import React, { useRef, useEffect, useCallback, useMemo } from 'react';

/**
 * 파티클 클래스 - 개별 파티클의 속성과 동작 정의
 */
class Particle {
  constructor(x, y, effect, mode) {
    this.x = x;
    this.y = y;
    this.initialX = x;
    this.initialY = y;
    this.effect = effect;
    this.mode = mode;
    
    // 물리 속성
    this.vx = (Math.random() - 0.5) * 4;
    this.vy = (Math.random() - 0.5) * 4;
    this.life = 1.0;
    this.maxLife = Math.random() * 60 + 60;
    this.age = 0;
    
    // 시각적 속성
    this.size = Math.random() * 20 + 10;
    this.rotation = Math.random() * Math.PI * 2;
    this.rotationSpeed = (Math.random() - 0.5) * 0.2;
    this.opacity = 1.0;
    
    // 애니메이션 속성
    this.bounce = Math.random() * 0.1 + 0.05;
    this.gravity = mode === 'dirty' ? 0.1 : -0.05;
    this.scale = 1.0;
    this.targetScale = Math.random() * 0.5 + 0.5;
    
    // 모드별 고유 속성
    if (mode === 'clean') {
      this.sparkle = Math.random() > 0.5;
      this.trail = [];
      this.maxTrailLength = 5;
    } else {
      this.jitter = Math.random() * 2 + 1;
      this.sink = true;
    }
  }
  
  update(deltaTime = 1) {
    this.age += deltaTime;
    this.life = Math.max(0, 1 - (this.age / this.maxLife));
    
    if (this.mode === 'clean') {
      this.updateCleanMode(deltaTime);
    } else {
      this.updateDirtyMode(deltaTime);
    }
    
    this.rotation += this.rotationSpeed * deltaTime;
    this.scale += (this.targetScale - this.scale) * 0.1 * deltaTime;
    this.opacity = this.life * 0.8 + 0.2;
  }
  
  updateCleanMode(deltaTime) {
    this.x += this.vx * deltaTime;
    this.y += this.vy * deltaTime;
    this.vy += this.gravity * deltaTime;
    
    const dx = this.initialX - this.x;
    const dy = this.initialY - this.y;
    const distance = Math.sqrt(dx * dx + dy * dy);
    
    if (distance > 50) {
      this.vx += dx * 0.001 * deltaTime;
      this.vy += dy * 0.001 * deltaTime;
    }
    
    this.vx *= 0.99;
    this.vy *= 0.99;
    
    if (this.sparkle) {
      this.opacity = 0.5 + Math.sin(this.age * 0.3) * 0.3;
    }
    
    this.trail.push({ x: this.x, y: this.y, opacity: this.opacity });
    if (this.trail.length > this.maxTrailLength) {
      this.trail.shift();
    }
  }
  
  updateDirtyMode(deltaTime) {
    this.x += (Math.random() - 0.5) * this.jitter * deltaTime;
    this.y += (Math.random() - 0.5) * this.jitter * deltaTime;
    
    if (this.sink) {
      this.vy += this.gravity * deltaTime;
      this.y += this.vy * deltaTime;
    }
    
    this.scale = 1.0 + Math.sin(this.age * 0.2) * this.bounce;
    this.opacity = this.life;
  }
  
  isAlive() {
    return this.life > 0;
  }
}

/**
 * ParticleSystem 컴포넌트
 */
const ParticleSystem = ({ hands, effect, mode, videoSize, style }) => {
  const canvasRef = useRef(null);
  const particlesRef = useRef([]);
  const animationFrameRef = useRef(null);
  const lastFrameTimeRef = useRef(performance.now());
  
  const config = useMemo(() => ({
    maxParticles: 500,
    emissionRate: mode === 'clean' ? 3 : 5,
    colors: {
      clean: ['#FFD700', '#FF69B4', '#00FFFF', '#FF1493', '#00FF7F'],
      dirty: ['#8B4513', '#A0522D', '#D2691E', '#CD853F', '#DEB887']
    }
  }), [mode]);

  const createParticle = useCallback((x, y) => {
    return new Particle(x, y, effect, mode);
  }, [effect, mode]);

  const emitParticles = useCallback(() => {
    if (!hands || hands.length === 0) return;
    
    const particles = particlesRef.current;
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    hands.forEach(hand => {
      if (hand.keyPoints) {
        const fingertips = [
          hand.keyPoints.thumb?.tip,
          hand.keyPoints.index?.tip,
          hand.keyPoints.middle?.tip,
          hand.keyPoints.ring?.tip,
          hand.keyPoints.pinky?.tip
        ].filter(Boolean);
        
        fingertips.forEach(tip => {
          if (Math.random() < (config.emissionRate / 60)) {
            const x = tip.x * canvas.width;
            const y = tip.y * canvas.height;
            
            const offsetX = (Math.random() - 0.5) * 50;
            const offsetY = (Math.random() - 0.5) * 50;
            
            const particle = createParticle(x + offsetX, y + offsetY);
            particles.push(particle);
          }
        });
      }
    });
    
    if (particles.length > config.maxParticles) {
      particles.splice(0, particles.length - config.maxParticles);
    }
  }, [hands, config, createParticle]);

  const updateParticles = useCallback((deltaTime) => {
    const particles = particlesRef.current;
    particles.forEach(particle => particle.update(deltaTime));
    particlesRef.current = particles.filter(particle => particle.isAlive());
  }, []);

  const renderParticles = useCallback(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    const particles = particlesRef.current;
    
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.globalCompositeOperation = mode === 'clean' ? 'screen' : 'source-over';
    
    particles.forEach(particle => {
      ctx.save();
      ctx.translate(particle.x, particle.y);
      ctx.rotate(particle.rotation);
      ctx.scale(particle.scale, particle.scale);
      ctx.globalAlpha = particle.opacity;
      
      // 이펙트 그리기
      ctx.font = `${particle.size}px Arial`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(particle.effect, 0, 0);
      
      ctx.restore();
    });
    
    ctx.globalCompositeOperation = 'source-over';
  }, [mode]);

  const animate = useCallback(() => {
    const currentTime = performance.now();
    const deltaTime = Math.min((currentTime - lastFrameTimeRef.current) / 16.67, 2);
    lastFrameTimeRef.current = currentTime;
    
    emitParticles();
    updateParticles(deltaTime);
    renderParticles();
    
    animationFrameRef.current = requestAnimationFrame(animate);
  }, [emitParticles, updateParticles, renderParticles]);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas || !videoSize.width || !videoSize.height) return;
    
    canvas.width = videoSize.width;
    canvas.height = videoSize.height;
    canvas.style.width = '100%';
    canvas.style.height = '100%';
  }, [videoSize]);

  useEffect(() => {
    if (hands && hands.length > 0) {
      if (!animationFrameRef.current) {
        animationFrameRef.current = requestAnimationFrame(animate);
      }
    } else {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
        animationFrameRef.current = null;
      }
    }
    
    return () => {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
        animationFrameRef.current = null;
      }
    };
  }, [hands, animate]);

  useEffect(() => {
    particlesRef.current = [];
  }, [mode, effect]);

  useEffect(() => {
    return () => {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
      particlesRef.current = [];
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      style={{
        position: 'absolute',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        pointerEvents: 'none',
        transform: 'scaleX(-1)',
        ...style
      }}
    />
  );
};

export default ParticleSystem;