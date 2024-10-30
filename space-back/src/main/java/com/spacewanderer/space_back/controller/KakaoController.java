package com.spacewanderer.space_back.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.spacewanderer.space_back.entity.UserEntity;
import com.spacewanderer.space_back.service.KakaoService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/auth/oauth2")
@RequiredArgsConstructor
public class KakaoController {
    private final KakaoService kakaoService;

}
