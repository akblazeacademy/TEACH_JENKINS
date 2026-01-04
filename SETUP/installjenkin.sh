#!/bin/bash
set -e

echo "🔄 Updating system..."
sudo apt update -y

echo "☕ Installing Java (required for Jenkins)..."
sudo apt install -y openjdk-17-jdk

echo "🔑 Adding Jenkins GPG key..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "📦 Adding Jenkins repository..."
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "🔄 Updating package index..."
sudo apt update -y

echo "🚀 Installing Jenkins..."
sudo apt install -y jenkins

echo "▶️ Starting Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "✅ Jenkins installed successfully!"
echo "🌐 Access Jenkins at: http://<VM_PUBLIC_IP>:8080"
echo "🔑 Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
