#!/bin/bash

# MIAGO Mobile Device Testing Script
# Tests connectivity and functionality of mobile devices connected to MIAGO platform

set -e

echo "=========================================="
echo "MIAGO Mobile Device Testing Suite"
echo "Version: 1.0.1.0.11.1.0.1"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if device is connected
echo "Step 1: Device Detection"
echo "━━━━━━━━━━━━━━━━━━━━━━"

# Check for Android devices
if command -v adb &> /dev/null; then
    echo "Checking for Android devices..."
    ANDROID_DEVICES=$(adb devices | grep -v "List" | grep "device$" | wc -l)
    if [ $ANDROID_DEVICES -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Android device(s) detected: $ANDROID_DEVICES"
        DEVICE_TYPE="android"
        DEVICE_ID=$(adb devices | grep "device$" | head -1 | awk '{print $1}')
    else
        echo -e "${YELLOW}⚠${NC} No Android devices detected"
    fi
else
    echo -e "${YELLOW}⚠${NC} adb not installed"
fi

# Check for iOS devices
if command -v ios-deploy &> /dev/null; then
    echo "Checking for iOS devices..."
    IOS_DEVICES=$(ios-deploy -c 2>/dev/null | wc -l)
    if [ $IOS_DEVICES -gt 0 ]; then
        echo -e "${GREEN}✓${NC} iOS device(s) detected: $IOS_DEVICES"
        DEVICE_TYPE="ios"
    else
        echo -e "${YELLOW}⚠${NC} No iOS devices detected"
    fi
else
    echo -e "${YELLOW}⚠${NC} ios-deploy not installed"
fi

if [ -z "$DEVICE_TYPE" ]; then
    echo -e "${RED}✗${NC} No devices detected. Connect a device and try again."
    exit 1
fi

echo ""
echo "Step 2: Port Forwarding Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$DEVICE_TYPE" = "android" ]; then
    echo "Setting up port forwarding for Android..."
    
    # Forward MIAGO ports
    adb forward tcp:73571 tcp:73571
    adb forward tcp:6379 tcp:6379
    adb forward tcp:8080 tcp:8080
    adb forward tcp:3003 tcp:3003
    
    echo -e "${GREEN}✓${NC} Port forwarding configured"
    echo "  - OAuth Entry: 73571"
    echo "  - Redis: 6379"
    echo "  - HTTP Server: 8080"
    echo "  - Docusaurus: 3003"
fi

echo ""
echo "Step 3: Service Connectivity Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_port() {
    local port=$1
    local service=$2
    
    if command -v nc &> /dev/null; then
        if nc -z -w2 localhost $port 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $service (port $port) - ACCESSIBLE"
            return 0
        else
            echo -e "${RED}✗${NC} $service (port $port) - NOT ACCESSIBLE"
            return 1
        fi
    else
        if timeout 2 bash -c "cat < /dev/null > /dev/tcp/localhost/$port" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $service (port $port) - ACCESSIBLE"
            return 0
        else
            echo -e "${RED}✗${NC} $service (port $port) - NOT ACCESSIBLE"
            return 1
        fi
    fi
}

# Test each service
test_port 73571 "OAuth Entry"
test_port 6379 "Redis"
test_port 8080 "HTTP Server"
test_port 3003 "Docusaurus"

echo ""
echo "Step 4: Device Information"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$DEVICE_TYPE" = "android" ]; then
    echo "Device ID: $DEVICE_ID"
    
    # Get device info
    MODEL=$(adb -s $DEVICE_ID shell getprop ro.product.model)
    ANDROID_VERSION=$(adb -s $DEVICE_ID shell getprop ro.build.version.release)
    SDK_VERSION=$(adb -s $DEVICE_ID shell getprop ro.build.version.sdk)
    
    echo "Model: $MODEL"
    echo "Android Version: $ANDROID_VERSION"
    echo "SDK Version: $SDK_VERSION"
    
    # Check if MIAGO app is installed
    echo ""
    echo "Checking for MIAGO app..."
    if adb -s $DEVICE_ID shell pm list packages | grep -q "ai.miago"; then
        echo -e "${GREEN}✓${NC} MIAGO app installed"
    else
        echo -e "${YELLOW}⚠${NC} MIAGO app not installed"
    fi
fi

echo ""
echo "Step 5: Network Performance Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$DEVICE_TYPE" = "android" ]; then
    echo "Getting device IP address..."
    DEVICE_IP=$(adb -s $DEVICE_ID shell ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    
    if [ -n "$DEVICE_IP" ]; then
        echo "Device IP: $DEVICE_IP"
        
        # Test ping
        echo "Testing latency..."
        PING_RESULT=$(ping -c 5 $DEVICE_IP 2>/dev/null | tail -1)
        if [ -n "$PING_RESULT" ]; then
            echo -e "${GREEN}✓${NC} Ping test: $PING_RESULT"
        else
            echo -e "${YELLOW}⚠${NC} Ping test failed"
        fi
    else
        echo -e "${YELLOW}⚠${NC} Could not determine device IP"
    fi
fi

echo ""
echo "Step 6: Security Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━"

# Check if services are using encryption
echo "Checking TLS/SSL configuration..."

for port in 8080 3003; do
    if timeout 2 bash -c "echo | openssl s_client -connect localhost:$port 2>/dev/null" | grep -q "Verify return code"; then
        echo -e "${GREEN}✓${NC} Port $port: TLS enabled"
    else
        echo -e "${YELLOW}⚠${NC} Port $port: TLS not detected (may be HTTP)"
    fi
done

echo ""
echo "Step 7: Storage and Resources"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$DEVICE_TYPE" = "android" ]; then
    # Check storage
    STORAGE=$(adb -s $DEVICE_ID shell df /data | tail -1 | awk '{print "Used: "$3" Available: "$4}')
    echo "Storage: $STORAGE"
    
    # Check battery
    BATTERY=$(adb -s $DEVICE_ID shell dumpsys battery | grep level | awk '{print $2}')
    echo "Battery Level: $BATTERY%"
    
    # Check memory
    MEMORY=$(adb -s $DEVICE_ID shell cat /proc/meminfo | grep MemAvailable | awk '{print $2" "$3}')
    echo "Available Memory: $MEMORY"
fi

echo ""
echo "Step 8: Generate Test Report"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

REPORT_FILE="mobile-device-test-report-$(date +%Y%m%d-%H%M%S).txt"

cat > $REPORT_FILE << EOREPORT
MIAGO Mobile Device Test Report
Generated: $(date)
========================================

Device Information:
- Type: $DEVICE_TYPE
- Device ID: ${DEVICE_ID:-N/A}
- Model: ${MODEL:-N/A}
- OS Version: ${ANDROID_VERSION:-N/A}
- IP Address: ${DEVICE_IP:-N/A}

Service Connectivity:
- OAuth Entry (73571): $(test_port 73571 "OAuth" > /dev/null && echo "PASS" || echo "FAIL")
- Redis (6379): $(test_port 6379 "Redis" > /dev/null && echo "PASS" || echo "FAIL")
- HTTP Server (8080): $(test_port 8080 "HTTP" > /dev/null && echo "PASS" || echo "FAIL")
- Docusaurus (3003): $(test_port 3003 "Docs" > /dev/null && echo "PASS" || echo "FAIL")

Network Performance:
- Latency: ${PING_RESULT:-Not tested}

Device Resources:
- Storage: ${STORAGE:-Not available}
- Battery: ${BATTERY:-Not available}%
- Memory: ${MEMORY:-Not available}

Recommendations:
- Ensure all services are running on the device
- Check firewall settings if connectivity fails
- Verify MIAGO app is properly installed
- Test with different network conditions

Next Steps:
1. Review service logs for any errors
2. Test actual app functionality
3. Verify data synchronization
4. Test offline capabilities
5. Perform security audit

EOREPORT

echo -e "${GREEN}✓${NC} Report generated: $REPORT_FILE"

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo ""
echo "Device Type: $DEVICE_TYPE"
echo "Device ID: ${DEVICE_ID:-N/A}"
echo "Report: $REPORT_FILE"
echo ""
echo "To view full report:"
echo "  cat $REPORT_FILE"
echo ""
echo "To test again:"
echo "  ./test-mobile-device.sh"
echo ""
echo "=========================================="
echo "Testing Complete"
echo "=========================================="
