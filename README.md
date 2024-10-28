# STX Mobile Wallet

A secure and feature-rich mobile wallet for managing Stacks (STX) tokens, built with React Native. This wallet provides a seamless experience for managing STX tokens with advanced features like biometric authentication, QR code scanning, and push notifications.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey.svg)
![React Native](https://img.shields.io/badge/React%20Native-v0.72.0-blue.svg)

## Features

### Core Functionality
- ✅ Create and manage multiple STX wallets
- ✅ Send and receive STX tokens
- ✅ Real-time balance updates
- ✅ Transaction history tracking
- ✅ Support for both Testnet and Mainnet

### Security
- 🔐 Biometric authentication (TouchID/FaceID)
- 🔒 Encrypted wallet storage
- 🛡️ Secure key management
- 🔑 Session management
- 🔍 Address validation

### User Experience
- 📱 Clean, intuitive interface
- 📷 QR code scanning for addresses
- 🔔 Push notifications for transactions
- 📊 Detailed transaction history
- 🔄 Automatic balance updates

## Getting Started

### Prerequisites

- Node.js (v14 or later)
- npm or yarn
- React Native development environment
- iOS: XCode (for iOS development)
- Android: Android Studio (for Android development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/stx-mobile-wallet.git
cd stx-mobile-wallet
```

2. Install dependencies:
```bash
npm install
# or
yarn install
```

3. Install iOS dependencies (iOS only):
```bash
cd ios
pod install
cd ..
```

4. Setup environment variables:
```bash
cp .env.example .env
```
Edit `.env` file with your configuration values.

### Running the App

#### iOS
```bash
npm run ios
# or
yarn ios
```

#### Android
```bash
npm run android
# or
yarn android
```

## Project Structure

```
stx-mobile-wallet/
├── src/
│   ├── components/    # Reusable UI components
│   ├── screens/       # Screen components
│   ├── navigation/    # Navigation configuration
│   ├── services/      # API and blockchain services
│   ├── utils/         # Utility functions
│   └── constants/     # Constants and configuration
├── ios/               # iOS native code
├── android/           # Android native code
└── __tests__/        # Test files
```

## Configuration

### Network Selection
By default, the wallet connects to the Stacks Testnet. To switch to Mainnet, modify the network configuration in `src/constants/config.js`:

```javascript
export const NETWORK = new StacksMainnet();
```

### Security Configuration
Ensure proper security settings in `src/constants/security.js`:

```javascript
export const SECURITY_CONFIG = {
  requiredBiometric: true,
  autoLockTimeout: 300000, // 5 minutes
  maxAttempts: 3
};
```

## Testing

Run unit tests:
```bash
npm test
```

Run integration tests:
```bash
npm run test:integration
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Security

If you discover any security issues, please report them via our security advisory board or email them to security@yourdomain.com.

### Security Best Practices
- Never share your private keys
- Always verify recipient addresses
- Enable biometric authentication
- Keep your app updated
- Use a secure internet connection

## API Documentation

### Stacks API Endpoints
The wallet interacts with the following Stacks API endpoints:

- Balance Check: `GET /extended/v1/address/${address}/balances`
- Transaction History: `GET /extended/v1/address/${address}/transactions`
- Broadcast Transaction: `POST /v2/transactions`

Complete API documentation can be found in the [Stacks API Reference](https://docs.stacks.co/api).

## Troubleshooting

Common issues and their solutions:

1. **Balance not updating**
   - Check internet connection
   - Verify network configuration
   - Ensure correct address format

2. **Biometric authentication issues**
   - Check device compatibility
   - Verify permissions
   - Reset biometric settings

3. **Transaction failures**
   - Verify sufficient balance
   - Check network fees
   - Confirm recipient address

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- Stacks Foundation for blockchain infrastructure
- React Native community for mobile development tools
- Open source contributors

## Contact

Your Name - [@yourtwitter](https://twitter.com/yourtwitter)
Project Link: [https://github.com/yourusername/stx-mobile-wallet](https://github.com/yourusername/stx-mobile-wallet)

## Changelog

### [1.1.0] - 2024-10-28
- Added multiple wallet support
- Implemented biometric authentication
- Added QR code functionality
- Enhanced transaction history
- Improved security features

### [1.0.0] - 2024-10-27
- Initial release
- Basic wallet functionality
- Balance checking
- Send/receive capabilities