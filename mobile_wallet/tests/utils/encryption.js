// utils/encryption.js
import CryptoJS from 'crypto-js';

// Basic encryption utility for the initial version
const ENCRYPTION_KEY = 'initial-encryption-key';

export const encrypt = async (data) => {
  try {
    return CryptoJS.AES.encrypt(data, ENCRYPTION_KEY).toString();
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