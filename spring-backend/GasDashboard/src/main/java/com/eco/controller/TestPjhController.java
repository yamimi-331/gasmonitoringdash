package com.eco.controller;

import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.RestTemplate;

@Controller
public class TestPjhController {
    @GetMapping("/testPjh")
    public String showDashboard(@RequestParam(name="city", required=false) String city, Model model) {
    	try {
            RestTemplate restTemplate = new RestTemplate();

            String urlStr = "http://localhost:8000/api/gas/prediction";
            // city 파라미터가 있으면 쿼리 붙이기
//            if(city != null && !city.isEmpty()) {
//                // 직접 인코딩해서 붙임 (UriComponentsBuilder 대신)
//                urlStr += "?city=" + URLEncoder.encode(city, StandardCharsets.UTF_8.toString());
//            }
            
            URI url = new URI(urlStr);
            Map<String, String> response = restTemplate.getForObject(url, Map.class);

            // 응답에서 base64 이미지 꺼내기
            String base64Image = "";
            if (response != null && response.containsKey("monthly_trend")) {
                base64Image = response.get("monthly_trend");
            } else if (response != null && response.containsKey("error")) {
                model.addAttribute("error", response.get("error"));
            }

            // JSP에 데이터 전달
            model.addAttribute("selectedCity", city);
            model.addAttribute("chartImage", base64Image);

        } catch (Exception e) {
            model.addAttribute("error", "서버 호출 중 오류 발생: " + e.getMessage());
        }

        return "testPjh";
    }
}
