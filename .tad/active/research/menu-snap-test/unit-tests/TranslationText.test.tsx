import React from 'react';
import { render, screen } from '@testing-library/react-native';
import { TranslationText } from '../TranslationText';

describe('TranslationText', () => {
  it('renders translated text when available', () => {
    render(
      <TranslationText
        originalText="Tom Yum Goong"
        translatedText="Spicy shrimp soup"
        isLoading={false}
      />
    );

    expect(screen.getByText('Spicy shrimp soup')).toBeTruthy();
  });

  it('shows loading indicator when translating', () => {
    render(
      <TranslationText
        originalText="Tom Yum Goong"
        translatedText={undefined}
        isLoading={true}
      />
    );

    expect(screen.getByLabelText('Translating')).toBeTruthy();
  });

  it('shows original text as fallback when translation is null', () => {
    render(
      <TranslationText
        originalText="Tom Yum Goong"
        translatedText={null}
        isLoading={false}
      />
    );

    expect(screen.getByText('Tom Yum Goong')).toBeTruthy();
  });

  it('shows error state when translation failed', () => {
    render(
      <TranslationText
        originalText="Tom Yum Goong"
        translatedText={undefined}
        isLoading={false}
        error="Translation service unavailable"
      />
    );

    expect(screen.getByText('Tom Yum Goong')).toBeTruthy();
    expect(screen.getByLabelText('Translation failed')).toBeTruthy();
  });

  it('renders both original and translated for comparison mode', () => {
    render(
      <TranslationText
        originalText="Tom Yum Goong"
        translatedText="Spicy shrimp soup"
        isLoading={false}
        showOriginal={true}
      />
    );

    expect(screen.getByText('Tom Yum Goong')).toBeTruthy();
    expect(screen.getByText('Spicy shrimp soup')).toBeTruthy();
  });

  it('handles CJK characters correctly', () => {
    render(
      <TranslationText
        originalText="Mapo Doufu"
        translatedText="Spicy tofu"
        isLoading={false}
      />
    );

    expect(screen.getByText('Spicy tofu')).toBeTruthy();
  });

  it('has correct accessibility for screen readers', () => {
    render(
      <TranslationText
        originalText="Pad Thai"
        translatedText="Stir-fried rice noodles"
        isLoading={false}
      />
    );

    expect(
      screen.getByLabelText('Pad Thai translated as Stir-fried rice noodles')
    ).toBeTruthy();
  });
});
