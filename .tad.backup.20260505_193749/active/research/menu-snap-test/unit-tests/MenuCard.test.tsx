import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react-native';
import { MenuCard } from '../MenuCard';

// Mock navigation
const mockNavigate = jest.fn();
jest.mock('@react-navigation/native', () => ({
  useNavigation: () => ({ navigate: mockNavigate }),
}));

const defaultProps = {
  id: 'dish-001',
  originalName: 'Pad Thai',
  translatedName: 'Stir-fried rice noodles',
  price: '120 THB',
  dietaryTags: ['gluten-free'],
  imageUri: 'https://example.com/padthai.jpg',
};

describe('MenuCard', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders dish name and translated name', () => {
    render(<MenuCard {...defaultProps} />);

    expect(screen.getByText('Pad Thai')).toBeTruthy();
    expect(screen.getByText('Stir-fried rice noodles')).toBeTruthy();
  });

  it('renders price', () => {
    render(<MenuCard {...defaultProps} />);

    expect(screen.getByText('120 THB')).toBeTruthy();
  });

  it('renders dietary tags as badges', () => {
    render(<MenuCard {...defaultProps} dietaryTags={['vegan', 'gluten-free']} />);

    expect(screen.getByText('vegan')).toBeTruthy();
    expect(screen.getByText('gluten-free')).toBeTruthy();
  });

  it('navigates to dish detail on tap', () => {
    render(<MenuCard {...defaultProps} />);

    fireEvent.press(screen.getByRole('button'));
    expect(mockNavigate).toHaveBeenCalledWith('DishDetail', { id: 'dish-001' });
  });

  it('handles missing translated name gracefully', () => {
    render(<MenuCard {...defaultProps} translatedName={undefined} />);

    expect(screen.getByText('Pad Thai')).toBeTruthy();
    // Should show a "translating..." indicator or fallback
    expect(screen.getByLabelText('Translation pending')).toBeTruthy();
  });

  it('truncates very long dish names', () => {
    const longName = 'A'.repeat(60);
    render(<MenuCard {...defaultProps} originalName={longName} />);

    // Component should render without crashing
    expect(screen.getByText(longName)).toBeTruthy();
  });

  it('has correct accessibility label', () => {
    render(<MenuCard {...defaultProps} />);

    expect(
      screen.getByLabelText('Pad Thai, Stir-fried rice noodles, 120 THB')
    ).toBeTruthy();
  });

  it('renders empty dietary tags without crashing', () => {
    render(<MenuCard {...defaultProps} dietaryTags={[]} />);

    expect(screen.getByText('Pad Thai')).toBeTruthy();
  });
});
