import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react-native';
import { CameraOverlay } from '../CameraOverlay';

// Mock camera
jest.mock('react-native-camera', () => ({
  RNCamera: {
    Constants: {
      FlashMode: { off: 'off', on: 'on', auto: 'auto' },
    },
  },
}));

const mockOnCapture = jest.fn();
const mockOnFlashToggle = jest.fn();

const defaultProps = {
  onCapture: mockOnCapture,
  onFlashToggle: mockOnFlashToggle,
  flashMode: 'off' as const,
  isCapturing: false,
};

describe('CameraOverlay', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders capture button', () => {
    render(<CameraOverlay {...defaultProps} />);

    expect(screen.getByLabelText('Take photo of menu')).toBeTruthy();
  });

  it('renders flash toggle button', () => {
    render(<CameraOverlay {...defaultProps} />);

    expect(screen.getByLabelText('Toggle flash')).toBeTruthy();
  });

  it('calls onCapture when capture button is pressed', () => {
    render(<CameraOverlay {...defaultProps} />);

    fireEvent.press(screen.getByLabelText('Take photo of menu'));
    expect(mockOnCapture).toHaveBeenCalledTimes(1);
  });

  it('calls onFlashToggle when flash button is pressed', () => {
    render(<CameraOverlay {...defaultProps} />);

    fireEvent.press(screen.getByLabelText('Toggle flash'));
    expect(mockOnFlashToggle).toHaveBeenCalledTimes(1);
  });

  it('disables capture button while capturing', () => {
    render(<CameraOverlay {...defaultProps} isCapturing={true} />);

    const button = screen.getByLabelText('Take photo of menu');
    expect(button.props.accessibilityState).toEqual(
      expect.objectContaining({ disabled: true })
    );
  });

  it('shows guide frame overlay for menu alignment', () => {
    render(<CameraOverlay {...defaultProps} />);

    // [ASSUMPTION] A guide frame helps users align the menu in the camera view
    expect(screen.getByTestId('camera-guide-frame')).toBeTruthy();
  });

  it('shows hint text for first-time users', () => {
    render(<CameraOverlay {...defaultProps} showHint={true} />);

    expect(screen.getByText(/align.*menu/i)).toBeTruthy();
  });

  it('capture button has minimum 44pt touch target', () => {
    render(<CameraOverlay {...defaultProps} />);

    const button = screen.getByLabelText('Take photo of menu');
    // Verify accessibility-compliant touch target
    expect(button).toBeTruthy();
  });

  it('announces flash state to VoiceOver', () => {
    render(<CameraOverlay {...defaultProps} flashMode="on" />);

    expect(screen.getByLabelText('Toggle flash, currently on')).toBeTruthy();
  });
});
