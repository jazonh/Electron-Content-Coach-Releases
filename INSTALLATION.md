# 📦 Electron Content Coach Installation Guide

## 🚀 Quick Installation (Recommended)

The fastest way to install Electron Content Coach is using our automated installer:

```bash
curl -s https://raw.githubusercontent.com/YOUR_USERNAME/Electron-Content-Coach-Releases/main/install.sh | bash
```

This script will:
- ✅ Download the latest version automatically
- ✅ Install to your Applications folder
- ✅ Remove quarantine attributes for seamless updates
- ✅ Launch the app immediately

## 📥 Manual Installation

If you prefer to install manually:

### Step 1: Download
1. Go to the [Releases page](https://github.com/YOUR_USERNAME/Electron-Content-Coach-Releases/releases)
2. Download the latest `Electron-Content-Coach-v[VERSION].dmg` file

### Step 2: Install
1. Open the downloaded DMG file
2. Drag `Electron Next App` to your `/Applications` folder
3. Right-click the app and select "Open" (required for first launch due to macOS Gatekeeper)

### Step 3: Configure
1. Launch Electron Content Coach
2. Ensure you have a `.env` file configured with:
   - Supabase credentials
   - PyChomsky configuration
3. You're ready to start!

## 🔄 Updates

Electron Content Coach includes an automatic update system powered by `update-electron-app`:

- **Automatic Checks**: The app checks for updates on launch
- **Background Updates**: Updates download automatically via GitHub Releases
- **Seamless Installation**: Updates install without disrupting your workflow
- **Production Only**: Auto-updates only run in production builds

## 🛠️ Requirements

- **macOS 14.0** or later
- **Internet connection** for AI processing and updates
- **PyChomsky environment** configured with GPT-5 Mini access
- **Supabase database** with embedded brand guidelines

## 🚨 Troubleshooting

### "App can't be opened" Error
This happens with manually downloaded apps due to macOS Gatekeeper:

1. Right-click the app in Applications
2. Select "Open" from the context menu
3. Click "Open" in the security dialog

### Updates Not Working
If automatic updates fail:

1. Check your internet connection
2. Verify the repository URL in package.json
3. Ensure you're running a production build (not development)
4. As a last resort, reinstall using the quick installer

### PyChomsky Issues
If tone correction isn't working:

1. Verify PyChomsky virtual environment is set up (`npm run setup-pychomsky`)
2. Check that GPT-5 Mini model is accessible
3. Test PyChomsky connection: `npm run test-pychomsky`

### Supabase Connection Issues
If guidelines aren't loading:

1. Verify `.env` file contains correct Supabase credentials
2. Check that guidelines are embedded in the database
3. Test connection in the developer console

## 🔒 Security

Electron Content Coach is designed with security in mind:

- **Context Isolation**: Renderer process runs with context isolation enabled
- **No Node Integration**: Prevents direct Node.js access from renderer
- **Preload Scripts**: Secure IPC communication via preload bridge
- **Environment Variables**: Credentials stored in `.env` file (not committed)
- **No Data Collection**: Your content never leaves your device except for AI processing

## 🆘 Support

Need help? Contact the development team or check the main repository for documentation and troubleshooting guides.
