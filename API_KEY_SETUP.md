# API Key Setup Guide

## 🔐 Secure API Key Configuration

**IMPORTANT**: Never commit API keys to version control!

## Option 1: Environment Variable (Recommended)

### For Development:
```bash
export OPENAI_API_KEY="your-actual-api-key-here"
```

### For Xcode:
1. Open your project in Xcode
2. Go to Product → Scheme → Edit Scheme
3. Select "Run" → "Arguments" → "Environment Variables"
4. Add: `OPENAI_API_KEY` = `your-actual-api-key-here`

## Option 2: Info.plist (Alternative)

Add to your `Info.plist`:
```xml
<key>OPENAI_API_KEY</key>
<string>your-actual-api-key-here</string>
```

**Note**: This is less secure as the key is in the app bundle.

## Option 3: .env File (Advanced)

1. Create a `.env` file in your project root
2. Add: `OPENAI_API_KEY=your-actual-api-key-here`
3. Add `.env` to your `.gitignore`
4. Load the file in your app (requires additional setup)

## Getting Your OpenAI API Key

1. Go to https://platform.openai.com/api-keys
2. Create a new API key
3. Copy the key (starts with `sk-`)
4. Use one of the methods above to configure it

## Security Best Practices

- ✅ Use environment variables
- ✅ Never commit API keys
- ✅ Rotate keys regularly
- ✅ Use different keys for dev/prod
- ❌ Don't hardcode in source code
- ❌ Don't commit to version control
