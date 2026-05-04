#!/bin/bash
# Build Flutter web and copy to web_build folder for Vercel
echo "Building Flutter web..."
cd mobile_app
flutter build web --release --web-renderer canvaskit --base-href /app/
echo "Copying to web_build..."
cd ..
rm -rf web_build
cp -r mobile_app/build/web web_build
echo "Done! web_build/ ready for deployment"
echo "Commit web_build/ and push to Vercel"
