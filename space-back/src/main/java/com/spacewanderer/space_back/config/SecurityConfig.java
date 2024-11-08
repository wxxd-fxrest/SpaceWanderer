package com.spacewanderer.space_back.config;

import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())  // CSRF 보호 비활성화 (필요시)
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                    "/", 
                    "/api/v1/auth/oauth2/apple-login", 
                    "/api/v1/auth/oauth2/auto-login", 
                    "/api/v1/auth/oauth2/kakao-login",
                    "/api/v1/auth/oauth2/get-kakao-user/*",
                    "/api/v1/auth/oauth2/get-kakao-access-token",
                    "/api/v1/user/profile-update/*",
                    "/api/v1/user/check-nickname/*",
                    "/api/v1/walk/day-walking"
                ).permitAll()  // 인증 없이 접근 가능 경로
                .anyRequest().authenticated()  // 다른 요청은 인증 필요
            );

        return http.build();
    }

    @Bean
    protected CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(List.of(
            "http://localhost:1020",           // 로컬 테스트 주소
            "http://192.168.1.14:1020"        // 실기기에서 접근할 IP 주소
        ));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);  // 자격 증명 허용

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);

        return source;
    }
}
