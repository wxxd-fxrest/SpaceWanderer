package com.spacewanderer.space_back.config;

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
                    "/api/v1/auth/oauth2/get-kakao-access-token"
                ).permitAll()  // 인증 없이 접근 가능 경로
                .anyRequest().authenticated()  // 다른 요청은 인증 필요
            );

        return http.build();
    }

    @Bean
    protected CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        // configuration.addAllowedOrigin("http://localhost:3000"); // 허용할 출처
        configuration.addAllowedOrigin("*"); // 허용할 출처
        configuration.addAllowedMethod("*"); // 허용할 메서드
        configuration.addAllowedHeader("*"); // 허용할 헤더
        // configuration.setAllowCredentials(true); // 자격 증명 허용

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);

        return source;
    }
}
