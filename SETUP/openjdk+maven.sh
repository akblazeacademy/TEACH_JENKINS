#!/bin/bash
set -e

echo "==============================="
echo " Installing OpenJDK & Maven "
echo "==============================="

# -----------------------------
# Update system
# -----------------------------
echo "🔄 Updating system..."
sudo apt update -y

# -----------------------------
# Install OpenJDK 17
# -----------------------------
echo "☕ Installing OpenJDK 17..."
sudo apt install -y openjdk-17-jdk

# -----------------------------
# Detect JAVA_HOME
# -----------------------------
JAVA_HOME_PATH=$(readlink -f /usr/bin/java | sed "s:/bin/java::")

echo "📌 Detected JAVA_HOME: $JAVA_HOME_PATH"

# -----------------------------
# Set JAVA_HOME permanently
# -----------------------------
echo "🛠 Setting JAVA_HOME..."
sudo tee /etc/profile.d/java.sh > /dev/null <<EOF
export JAVA_HOME=$JAVA_HOME_PATH
export PATH=\$PATH:\$JAVA_HOME/bin
EOF

sudo chmod +x /etc/profile.d/java.sh

# -----------------------------
# Apply environment variables
# -----------------------------
source /etc/profile.d/java.sh

# -----------------------------
# Install Maven
# -----------------------------
echo "📦 Installing Maven..."
sudo apt install -y maven

# -----------------------------
# Verify installations
# -----------------------------
echo "==============================="
echo " Verification "
echo "==============================="

echo "Java Version:"
java -version

echo "Javac Version:"
javac -version

echo "Maven Version:"
mvn -version

echo "==============================="
echo "✅ Java & Maven installed successfully!"
echo "==============================="

