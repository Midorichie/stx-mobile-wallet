// utils/encryption.js
import CryptoJS from 'crypto-js';
import { getRandomValues } from 'react-native-get-random-values';

const ENCRYPTION_KEY = 'your-secure-encryption-key'; // In production, use secure key storage

export const encrypt = async (data) => {
  try {
    const encrypted = CryptoJS.AES.encrypt(data, ENCRYPTION_KEY).toString();
    return encrypted;
  } catch (error) {
    console.error('Encryption error:', error);
    throw error;
  }
};

export const decrypt = async (encryptedData) => {
  try {
    const decrypted = CryptoJS.AES.decrypt(encryptedData, ENCRYPTION_KEY);
    return decrypted.toString(CryptoJS.enc.Utf8);
  } catch (error) {
    console.error('Decryption error:', error);
    throw error;
  }
};