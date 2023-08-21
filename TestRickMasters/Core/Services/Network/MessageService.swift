//
//  MessageService.swift
//  TestRickMasters
//
//  Created by Roman Kiruxin on 09.08.2023.
//

import Alamofire
import UIKit

public enum MessageService {
    public static func showError(_ method: String, _ error: Error) {
        let err = [
            "Метод: \(method)",
            "Ошибка: \(error.localizedDescription)"
        ]

        debugMessage(title: "Произошла ошибка!", message: err.joined(separator: ", "))
    }

    static func showError(_ error: ApiErrorModel) {
        let err = [
            "Тип: \(error.type)",
            "Статус код: \(error.code)",
            "Запрос: \(error.request)",
            "Описание: \(error.message)"
        ]

        debugMessage(title: "Ошибка API запроса!", message: err.joined(separator: ", "))
    }

    public static func showError(_ error: AFError) {
        let err = [
            "Статус код: \(error.responseCode ?? -1)",
            "Запрос: \(error.url?.absoluteString ?? "n/n")",
            "Описание: \(error.localizedDescription)"
        ]

        debugMessage(title: "Ошибка API запроса!", message: err.joined(separator: ", "))
    }

    public static func showError(_ method: String, _ error: String) {
        let err = [
            "Метод: \(method)",
            "Ошибка: \(error)"
        ]

        debugMessage(title: "Произошла ошибка!", message: err.joined(separator: ", "))
    }
}

private extension MessageService {
    static func debugMessage(title: String, message: String) {
        debugPrint("😢😢😢 Что такое? - \(title), \(message)")
    }
}
