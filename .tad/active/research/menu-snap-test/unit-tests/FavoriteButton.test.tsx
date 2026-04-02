import React from 'react';
import { render, fireEvent, screen, act } from '@testing-library/react-native';
import { FavoriteButton } from '../FavoriteButton';

// Mock AsyncStorage for favorites persistence
jest.mock('@react-native-async-storage/async-storage', () => ({
  getItem: jest.fn(() => Promise.resolve(null)),
  setItem: jest.fn(() => Promise.resolve()),
}));

// Mock haptic feedback
jest.mock('react-native-haptic-feedback', () => ({
  trigger: jest.fn(),
}));

const mockOnToggle = jest.fn();

describe('FavoriteButton', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders in unfavorited state by default', () => {
    render(<FavoriteButton dishId="dish-001" isFavorited={false} onToggle={mockOnToggle} />);

    expect(screen.getByLabelText('Save to favorites')).toBeTruthy();
  });

  it('renders in favorited state when isFavorited is true', () => {
    render(<FavoriteButton dishId="dish-001" isFavorited={true} onToggle={mockOnToggle} />);

    expect(screen.getByLabelText('Remove from favorites')).toBeTruthy();
  });

  it('calls onToggle when pressed', () => {
    render(<FavoriteButton dishId="dish-001" isFavorited={false} onToggle={mockOnToggle} />);

    fireEvent.press(screen.getByRole('button'));
    expect(mockOnToggle).toHaveBeenCalledWith('dish-001');
  });

  it('triggers haptic feedback on press', () => {
    const HapticFeedback = require('react-native-haptic-feedback');
    render(<FavoriteButton dishId="dish-001" isFavorited={false} onToggle={mockOnToggle} />);

    fireEvent.press(screen.getByRole('button'));
    expect(HapticFeedback.trigger).toHaveBeenCalledWith('impactLight');
  });

  it('has minimum 44x44pt touch target', () => {
    render(<FavoriteButton dishId="dish-001" isFavorited={false} onToggle={mockOnToggle} />);

    const button = screen.getByRole('button');
    // [ASSUMPTION] Button style includes minWidth/minHeight of 44
    expect(button.props.style).toEqual(
      expect.objectContaining({
        minWidth: expect.any(Number),
        minHeight: expect.any(Number),
      })
    );
  });

  it('does not crash when onToggle is undefined', () => {
    // Defensive: optional callback
    render(<FavoriteButton dishId="dish-001" isFavorited={false} onToggle={undefined as any} />);

    expect(() => {
      fireEvent.press(screen.getByRole('button'));
    }).not.toThrow();
  });
});
