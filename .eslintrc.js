module.exports = {
  env: {
    browser: true,
    es6: true,
    jest: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier/@typescript-eslint",
    "plugin:react/recommended",
    "prettier",
  ],
  overrides: [
    {
      files: ["**/*.tsx"],
      rules: {
        "react/prop-types": "off",
      },
    },
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 6,
    sourceType: "module",
  },
  plugins: ["@typescript-eslint", "eslint-plugin-import"],
  root: true,
  rules: {
    "no-console": 1,
    "sort-imports": 1,
    "sort-keys": 1,
    "spaced-comment": ["error", "always", { block: { balanced: true } }],
  },
  settings: {
    react: {
      version: "detect",
    },
  },
}
