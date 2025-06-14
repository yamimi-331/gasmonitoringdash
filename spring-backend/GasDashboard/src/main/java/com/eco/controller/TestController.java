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
	private final String fastApiUrl = "http://localhost:8000/api/gas/prediction";

	@GetMapping("/gas/prediction")
	public String getGasPrediction(Model model) {
		try {
			// FastAPI 응답 JSON을 Map 형태로 파싱
			Map<String, Object> response = restTemplate.getForObject(fastApiUrl, Map.class);

			if (response != null && response.containsKey("models") && response.containsKey("visualizations")) {
				model.addAttribute("models", response.get("models"));
				model.addAttribute("visualizations", response.get("visualizations"));
			} else {
				model.addAttribute("error", "FastAPI 응답에 데이터가 없습니다.");
			}
		} catch (Exception e) {
			model.addAttribute("error", "FastAPI 요청 실패: " + e.getMessage());
		}

		return "test"; // gas_prediction.jsp
	}
}
