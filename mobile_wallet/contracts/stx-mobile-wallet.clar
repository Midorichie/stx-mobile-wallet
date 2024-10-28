// App.js
import React, { useState, useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { 
  SafeAreaView, 
  View, 
  Text, 
  TouchableOpacity, 
  StyleSheet,
  Alert,
  AppState
} from 'react-native';
import { Camera } from 'react-native-camera';
import QRCodeScanner from 'react-native-qrcode-scanner';
import AsyncStorage from '@react-native-async-storage/async-storage';
import PushNotification from 'react-native-push-notification';
import TouchID from 'react-native-touch-id';
import { 
  makeSTXTokenTransfer,
  getAddressFromPrivateKey,
  generateWallet,
  validateStacksAddress
} from '@stacks/transactions';
import { StacksTestnet, StacksMainnet } from '@stacks/network';
import { encrypt, decrypt } from './utils/encryption';

const Tab = createBottomTabNavigator();
const NETWORK = new StacksTestnet();
const ACCOUNTS_STORAGE_KEY = '@stx_wallet_accounts';
const TRANSACTION_HISTORY_KEY = '@stx_transaction_history';

// Components

const WalletScreen = ({ navigation }) => {
  const [activeWallet, setActiveWallet] = useState(null);
  const [wallets, setWallets] = useState([]);
  const [balance, setBalance] = useState(0);
  const [loading, setLoading] = useState(false);
  const [transactions, setTransactions] = useState([]);

  useEffect(() => {
    loadWallets();
    setupPushNotifications();
    AppState.addEventListener('change', handleAppStateChange);

    return () => {
      AppState.removeEventListener('change', handleAppStateChange);
    };
  }, []);

  const handleAppStateChange = (nextAppState) => {
    if (nextAppState === 'active') {
      authenticateUser();
    }
  };

  const authenticateUser = async () => {
    try {
      await TouchID.authenticate('Verify your identity', {
        title: 'Biometric Authentication',
      });
    } catch (error) {
      Alert.alert('Authentication Failed', 'Please try again');
      return false;
    }
    return true;
  };

  const setupPushNotifications = () => {
    PushNotification.configure({
      onNotification: function (notification) {
        console.log('NOTIFICATION:', notification);
      },
      permissions: {
        alert: true,
        badge: true,
        sound: true,
      },
      popInitialNotification: true,
    });
  };

  const loadWallets = async () => {
    try {
      const authenticated = await authenticateUser();
      if (!authenticated) return;

      const encryptedWallets = await AsyncStorage.getItem(ACCOUNTS_STORAGE_KEY);
      if (encryptedWallets) {
        const decryptedWallets = await decrypt(encryptedWallets);
        setWallets(JSON.parse(decryptedWallets));
        if (decryptedWallets.length > 0) {
          setActiveWallet(decryptedWallets[0]);
          await fetchBalance(decryptedWallets[0].address);
          await loadTransactionHistory(decryptedWallets[0].address);
        }
      }
    } catch (error) {
      console.error('Error loading wallets:', error);
      Alert.alert('Error', 'Failed to load wallets');
    }
  };

  const createNewWallet = async () => {
    try {
      setLoading(true);
      const newWallet = await generateWallet({
        secretKey: false,
        strength: 256
      });
      
      const address = getAddressFromPrivateKey(
        newWallet.privateKey,
        NETWORK.version
      );
      
      const walletData = {
        ...newWallet,
        address,
        label: `Wallet ${wallets.length + 1}`
      };

      const updatedWallets = [...wallets, walletData];
      const encryptedWallets = await encrypt(JSON.stringify(updatedWallets));
      await AsyncStorage.setItem(ACCOUNTS_STORAGE_KEY, encryptedWallets);
      
      setWallets(updatedWallets);
      setActiveWallet(walletData);
      
      PushNotification.localNotification({
        title: 'New Wallet Created',
        message: `Wallet ${wallets.length + 1} has been created successfully`,
      });

      await fetchBalance(address);
    } catch (error) {
      console.error('Error creating wallet:', error);
      Alert.alert('Error', 'Failed to create new wallet');
    } finally {
      setLoading(false);
    }
  };

  const loadTransactionHistory = async (address) => {
    try {
      const response = await fetch(
        `https://stacks-node-api.testnet.stacks.co/extended/v1/address/${address}/transactions`
      );
      const data = await response.json();
      setTransactions(data.results);
      await AsyncStorage.setItem(
        TRANSACTION_HISTORY_KEY,
        JSON.stringify(data.results)
      );
    } catch (error) {
      console.error('Error fetching transaction history:', error);
    }
  };

  return (
    <View style={styles.container}>
      <WalletHeader 
        activeWallet={activeWallet}
        balance={balance}
        onSwitchWallet={() => navigation.navigate('WalletList', { wallets })}
      />
      <TransactionList transactions={transactions} />
      <ActionButtons 
        onSend={() => navigation.navigate('Send')}
        onReceive={() => navigation.navigate('Receive')}
      />
    </View>
  );
};

const SendScreen = ({ navigation }) => {
  const [recipientAddress, setRecipientAddress] = useState('');
  const [amount, setAmount] = useState('');
  const [scanning, setScanning] = useState(false);

  const handleQRCodeScanned = ({ data }) => {
    if (validateStacksAddress(data)) {
      setRecipientAddress(data);
      setScanning(false);
    } else {
      Alert.alert('Invalid Address', 'The scanned QR code is not a valid STX address');
    }
  };

  const sendTransaction = async () => {
    try {
      const authenticated = await authenticateUser();
      if (!authenticated) return;

      // Transaction logic here
      // After successful transaction:
      PushNotification.localNotification({
        title: 'Transaction Sent',
        message: `${amount} STX sent to ${recipientAddress.slice(0, 8)}...`,
      });
    } catch (error) {
      Alert.alert('Transaction Failed', error.message);
    }
  };

  return (
    <View style={styles.container}>
      {scanning ? (
        <QRCodeScanner
          onRead={handleQRCodeScanned}
          topContent={
            <Text style={styles.centerText}>Scan recipient's QR code</Text>
          }
        />
      ) : (
        <SendForm
          recipientAddress={recipientAddress}
          amount={amount}
          onScan={() => setScanning(true)}
          onSend={sendTransaction}
        />
      )}
    </View>
  );
};

const ReceiveScreen = () => {
  const [qrValue, setQrValue] = useState('');

  useEffect(() => {
    if (activeWallet) {
      setQrValue(activeWallet.address);
    }
  }, [activeWallet]);

  return (
    <View style={styles.container}>
      <QRCode value={qrValue} size={200} />
      <Text style={styles.address}>{qrValue}</Text>
      <TouchableOpacity
        style={styles.button}
        onPress={() => Clipboard.setString(qrValue)}
      >
        <Text style={styles.buttonText}>Copy Address</Text>
      </TouchableOpacity>
    </View>
  );
};

// Navigation Setup
const App = () => {
  return (
    <NavigationContainer>
      <Tab.Navigator>
        <Tab.Screen name="Wallet" component={WalletScreen} />
        <Tab.Screen name="Send" component={SendScreen} />
        <Tab.Screen name="Receive" component={ReceiveScreen} />
      </Tab.Navigator>
    </NavigationContainer>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    padding: 20,
    backgroundColor: '#5546FF',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
  },
  walletInfo: {
    padding: 20,
  },
  transactionList: {
    flex: 1,
  },
  transaction: {
    padding: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  actionButtons: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    padding: 20,
  },
  button: {
    padding: 15,
    backgroundColor: '#5546FF',
    borderRadius: 8,
    minWidth: 120,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  qrContainer: {
    alignItems: 'center',
    padding: 20,
  },
  address: {
    marginTop: 20,
    fontSize: 16,
    textAlign: 'center',
  },
});

export default App;