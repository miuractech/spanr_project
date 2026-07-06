import { createContext, useContext, useState, type ReactNode } from 'react';
import { en } from './locales/en';
import { te } from './locales/te';

export type Locale = 'en' | 'te' | 'ta' | 'kn';

type Strings = typeof en;

const LOCALES: Record<Locale, Partial<Strings>> = { en, te, ta: {}, kn: {} };

function t(locale: Locale, key: keyof Strings): string {
  return (LOCALES[locale][key] ?? LOCALES.en[key] ?? key) as string;
}

interface I18nContextType {
  locale: Locale;
  setLocale: (l: Locale) => void;
  t: (key: keyof Strings) => string;
}

export const I18nContext = createContext<I18nContextType>({
  locale: 'en',
  setLocale: () => {},
  t: (key) => en[key] ?? key,
});

export function I18nProvider({ children }: { children: ReactNode }) {
  const saved = (localStorage.getItem('spanr_locale') as Locale | null) ?? 'en';
  const [locale, setLocaleState] = useState<Locale>(saved);

  const setLocale = (l: Locale) => {
    localStorage.setItem('spanr_locale', l);
    setLocaleState(l);
  };

  return (
    <I18nContext.Provider value={{ locale, setLocale, t: (key) => t(locale, key) }}>
      {children}
    </I18nContext.Provider>
  );
}

export function useI18n() {
  return useContext(I18nContext);
}

export type { Strings };
