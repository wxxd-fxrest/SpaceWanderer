package com.spacewanderer.space_back.utils;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Arrays;
import java.util.Base64;
import javax.crypto.spec.IvParameterSpec;

@Component
public class EncryptionUtil {
    
    @Value("${ALGORITHM}")
    private String algorithm;

    @Value("${SECRET_KEY}")
    private String secretKey;

    public String encrypt(String data) throws Exception {
        Cipher cipher = Cipher.getInstance(algorithm);
        
        SecretKeySpec keySpec = new SecretKeySpec(secretKey.getBytes(), "AES");

        // 랜덤 IV 생성
        byte[] iv = new byte[16]; // 16바이트 IV
        SecureRandom random = new SecureRandom();
        random.nextBytes(iv);
        IvParameterSpec ivSpec = new IvParameterSpec(iv);

        cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec);

        byte[] encrypted = cipher.doFinal(data.getBytes());

        // IV와 암호문을 합쳐서 반환 (IV + 암호문)
        byte[] combined = new byte[iv.length + encrypted.length];
        System.arraycopy(iv, 0, combined, 0, iv.length);
        System.arraycopy(encrypted, 0, combined, iv.length, encrypted.length);

        return Base64.getEncoder().encodeToString(combined);
    }

    public String decrypt(String encryptedData) throws Exception {
        // Base64로 인코딩된 데이터를 디코딩
        byte[] decoded = Base64.getDecoder().decode(encryptedData);

        // IV와 암호문 분리 (첫 16바이트는 IV)
        byte[] iv = Arrays.copyOfRange(decoded, 0, 16); // 첫 16바이트가 IV
        byte[] cipherText = Arrays.copyOfRange(decoded, 16, decoded.length);

        Cipher cipher = Cipher.getInstance(algorithm);

        SecretKeySpec keySpec = new SecretKeySpec(secretKey.getBytes(), "AES");
        IvParameterSpec ivSpec = new IvParameterSpec(iv);

        cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec);

        // 복호화 시도
        byte[] decrypted = cipher.doFinal(cipherText);

        return new String(decrypted, StandardCharsets.UTF_8);
    }
}