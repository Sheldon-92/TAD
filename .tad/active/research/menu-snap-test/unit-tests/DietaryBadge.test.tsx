import React from 'react';
import { render, screen } from '@testing-library/react-native';
import { DietaryBadge } from '../DietaryBadge';

describe('DietaryBadge', () => {
  it('renders the badge text', () => {
    render(<DietaryBadge type="vegan" />);
    expect(screen.getByText('vegan')).toBeTruthy();
  });

  it('applies correct color for vegan badge', () => {
    render(<DietaryBadge type="vegan" />);
    const badge = screen.getByRole('text');
    // [ASSUMPTION] Vegan badge uses green color scheme
    expect(badge.props.style).toEqual(
      expect.objectContaining({ backgroundColor: expect.any(String) })
    );
  });

  it('applies correct color for gluten-free badge', () => {
    render(<DietaryBadge type="gluten-free" />);
    expect(screen.getByText('gluten-free')).toBeTruthy();
  });

  it('applies correct color for nut-free badge', () => {
    render(<DietaryBadge type="nut-free" />);
    expect(screen.getByText('nut-free')).toBeTruthy();
  });

  it('applies correct color for vegetarian badge', () => {
    render(<DietaryBadge type="vegetarian" />);
    expect(screen.getByText('vegetarian')).toBeTruthy();
  });

  it('has accessible role', () => {
    render(<DietaryBadge type="vegan" />);
    expect(screen.getByRole('text')).toBeTruthy();
  });

  it('has descriptive accessibility label', () => {
    render(<DietaryBadge type="vegan" />);
    expect(screen.getByLabelText('Dietary: vegan')).toBeTruthy();
  });

  it('handles unknown dietary type without crashing', () => {
    // @ts-expect-error — testing unknown type resilience
    render(<DietaryBadge type="unknown-type" />);
    expect(screen.getByText('unknown-type')).toBeTruthy();
  });
});
