package com.eco.controller;

import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.client.RestTemplate;

@Controller
@RequestMapping("/test")
public class TestController {
	private final RestTemplate restTemplate = new RestTemplate();
	private final String fastApi2025Url = "http://localhost:8000/api/gas/supply/2025";

	@GetMapping("/gas/supply/2025/graph")
	public String getGasPrediction(Model model) {
		try {
            // FastAPI 응답 (JSON 형태의 Map)을 파싱
            Map<String, Object> response = restTemplate.getForObject(fastApi2025Url, Map.class);

            if (response != null && response.containsKey("plot_image_base64")) {
                // base64 이미지 문자열을 추출하여 모델에 추가
                String base64Image = (String) response.get("plot_image_base64");
                model.addAttribute("base64Image2025", base64Image); // JSP에서 사용할 이름
                model.addAttribute("message", response.get("message")); // 메시지도 함께 전달
            } else {
                model.addAttribute("error", "FastAPI 응답에 이미지 데이터가 없습니다.");
            }
        } catch (Exception e) {
            model.addAttribute("error", "FastAPI 요청 실패: " + e.getMessage());
        }

		return "test"; 
	}
	
	@GetMapping("/api-supply-prediction")
	public String getGasSupplyPrediction(Model model) {
		try {
            // FastAPI 응답 (JSON 형태의 Map)을 파싱
            Map<String, Object> response = restTemplate.getForObject("http://localhost:8000/api-supply-prediction", Map.class);

            if (response != null && response.containsKey("image_base64")) {
                // base64 이미지 문자열을 추출하여 모델에 추가
                String base64Image = (String) response.get("image_base64");
                model.addAttribute("newImage", base64Image); // JSP에서 사용할 이름
            } else {
                model.addAttribute("error", "FastAPI 응답에 이미지 데이터가 없습니다.");
            }
        } catch (Exception e) {
            model.addAttribute("error", "FastAPI 요청 실패: " + e.getMessage());
        }

		return "test"; 
	}
	
}
