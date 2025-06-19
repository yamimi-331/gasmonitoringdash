package com.eco.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
public class ServiceException extends RuntimeException{
	private static final long serialVersionUID = 1L;

	// 사용자 정의 메시지를 받는 생성자
	public ServiceException(String message) {
		super(message);
	}

	// 원인 예외(cause)까지 포함하는 생성자
	public ServiceException(String message, Throwable cause) {
		super(message, cause);
	}
}
