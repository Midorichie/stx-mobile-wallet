// App.js
import React, { useState, useEffect } from 'react';
import { 
  SafeAreaView, 
  View, 
  Text, 
  TouchableOpacity, 
  StyleSheet 
} from 'react-native';
import { 
  makeSTXTokenTransfer,
  getAddressFromPrivateKey,
  generateWallet
} from '@stacks/transactions';
import { StacksTestnet, StacksMainnet } from '@stacks/network';

const NETWORK = new StacksTestnet();

const STXWallet = () => {
  const [wallet, setWallet] = useState(null);
  const [balance, setBalance] = useState(0);
  const [loading, setLoading] = useState(false);

  const createWallet = async () => {
    try {
      setLoading(true);
      // Generate new wallet with 24 word seed phrase
      const newWallet = await generateWallet({
        secretKey: false,
        strength: 256 // 24 words
      });
      
      const address = getAddressFromPrivateKey(
        newWallet.privateKey,
        NETWORK.version
      );
      
      setWallet({
        ...newWallet,
        address
      });
      
      // Fetch initial balance
      fetchBalance(address);
    } catch (error) {
      console.error('Error creating wallet:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchBalance = async (address) => {
    try {
      const response = await fetch(
        `https://stacks-node-api.testnet.stacks.co/extended/v1/address/${address}/balances`
      );
      const data = await response.json();
      setBalance(parseInt(data.stx.balance) / 1000000); // Convert to STX
    } catch (error) {
      console.error('Error fetching balance:', error);
    }
  };

  const sendTransaction = async (recipientAddress, amount) => {
    try {
      setLoading(true);
      const txOptions = {
        recipient: recipientAddress,
        amount: amount * 1000000, // Convert STX to microSTX
        senderKey: wallet.privateKey,
        network: NETWORK,
        memo: 'Transfer from STX Mobile Wallet',
        nonce: 0, // You should fetch the proper nonce
        fee: 3000 // Standard fee, adjust as needed
      };

      const transaction = await makeSTXTokenTransfer(txOptions);
      const broadcastResponse = await broadcastTransaction(transaction, NETWORK);
      
      console.log('Transaction broadcast:', broadcastResponse);
      // Wait for confirmation and update balance
      await new Promise(resolve => setTimeout(resolve, 3000));
      fetchBalance(wallet.address);
    } catch (error) {
      console.error('Error sending transaction:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (wallet?.address) {
      const intervalId = setInterval(() => {
        fetchBalance(wallet.address);
      }, 30000); // Update balance every 30 seconds

      return () => clearInterval(intervalId);
    }
  }, [wallet]);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>STX Mobile Wallet</Text>
      </View>

      {!wallet ? (
        <TouchableOpacity 
          style={styles.button}
          onPress={createWallet}
          disabled={loading}
        >
          <Text style={styles.buttonText}>
            {loading ? 'Creating Wallet...' : 'Create New Wallet'}
          </Text>
        </TouchableOpacity>
      ) : (
        <View style={styles.walletInfo}>
          <Text style={styles.label}>Wallet Address:</Text>
          <Text style={styles.address}>{wallet.address}</Text>
          <Text style={styles.label}>Balance:</Text>
          <Text style={styles.balance}>{balance} STX</Text>
        </View>
      )}
    </SafeAreaView>
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
  label: {
    fontSize: 16,
    fontWeight: 'bold',
    marginTop: 10,
  },
  address: {
    fontSize: 14,
    marginTop: 5,
    padding: 10,
    backgroundColor: '#f5f5f5',
    borderRadius: 5,
  },
  balance: {
    fontSize: 24,
    marginTop: 5,
  },
  button: {
    margin: 20,
    padding: 15,
    backgroundColor: '#5546FF',
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default STXWallet;