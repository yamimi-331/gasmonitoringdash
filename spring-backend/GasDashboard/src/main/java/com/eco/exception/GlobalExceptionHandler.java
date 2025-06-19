package com.eco.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.protobuf.ServiceException;

@ControllerAdvice
public class GlobalExceptionHandler {
	/**
	 * ServiceException 예외를 처리하여 사용자에게 메시지와 상태코드 전달
	 * 
	 * @param ex 발생한 예외 객체
	 * @return ResponseEntity: 사용자에게 전달할 메시지와 상태코드
	 */
	@ExceptionHandler(ServiceException.class)
	@ResponseBody
	public ResponseEntity<String> handleServiceException(ServiceException ex) {
		// 예외 메시지를 포함하여 HTTP 500 응답 반환
		return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
				.header("Content-Type", "text/plain; charset=UTF-8").body(ex.getMessage());
	}
}
