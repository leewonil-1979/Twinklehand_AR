// index.js - React 앱 진입점
import React from 'react';
import ReactDOM from 'react-dom/client';
import CameraScreen from './screens/CameraScreen';

/**
 * 메인 App 컴포넌트
 */
const App = () => {
  return (
    <div className="app">
      <CameraScreen />
    </div>
  );
};

// React 18 방식으로 앱 렌더링
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);

console.log('🚀 TwinkleHands AR 시스템 시작!');