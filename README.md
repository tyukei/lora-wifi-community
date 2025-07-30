# LoRa WiFi Community Website

A futuristic 3D website for the LoRa WiFi community, built with Zig and designed for GitHub Pages deployment.

## Features

- 🚀 Futuristic 3D design with animations
- ⚡ Static site generation with Zig
- 🎨 Interactive 3D elements and parallax effects
- 📱 Responsive design
- 🌐 GitHub Pages ready

## Build Instructions

### Prerequisites

- Zig 0.11.0 or later

### Local Development

#### Option 1: Zig HTTP Server (推奨)
```bash
# サーバーをビルドして起動
zig build-exe server.zig
./server
```
ブラウザで `http://localhost:8000` を開く

#### Option 2: Python HTTP Server
```bash
cd src
python3 -m http.server 8000
```

#### Option 3: 静的サイトをビルド
```bash
zig build-exe build.zig
./build
```
その後 `public/index.html` をブラウザで開く

### Deployment

The site automatically deploys to GitHub Pages when you push to the `main` branch.

## Project Structure

```
lora-wifi-community/
├── build.zig           # Zig build script
├── build.zig.zon       # Zig project configuration
├── src/
│   ├── index.html      # Main HTML template
│   ├── style.css       # 3D futuristic styles
│   └── script.js       # Interactive JavaScript
├── public/             # Generated static files
└── .github/
    └── workflows/
        └── deploy.yml  # GitHub Actions workflow
```

## Technologies

- **LoRa/LoRaWAN**: Long-range, low-power wireless communication
- **Zig**: Static site generation
- **CSS3**: 3D transforms and animations
- **JavaScript**: Interactive elements
- **GitHub Pages**: Hosting

## License

MIT