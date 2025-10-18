# API Key Setup Guide

## 🔐 Secure API Key Configuration

**IMPORTANT**: Never commit API keys to version control!

## ✅ Recommended: .env File (Secure)

1. Create a `.env` file in your project root
2. Add: `OPENAI_API_KEY=your-actual-api-key-here`
3. The `.env` file is already in `.gitignore` for security
4. The app automatically loads the API key from the `.env` file

**Why this is secure:**
- ✅ `.env` file is ignored by git
- ✅ API key stays local to your machine
- ✅ Never gets bundled into the app
- ✅ Easy to manage and update

## Getting Your OpenAI API Key

1. Go to https://platform.openai.com/api-keys
2. Create a new API key
3. Copy the key (starts with `sk-`)
4. Use one of the methods above to configure it

## Security Best Practices

- ✅ Use .env files for local development
- ✅ Never commit API keys to version control
- ✅ Rotate keys regularly
- ✅ Use different keys for dev/prod
- ❌ Don't hardcode in source code
- ❌ Don't put keys in Info.plist (gets bundled into app)
- ❌ Don't commit to version control
