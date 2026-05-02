//
//  Article.swift
//  MovieListApp
//
//  Created by Nurtore on 02.05.2026.
//

import Foundation

// Главная структура ответа от Guardian
struct GuardianResponse: Codable {
    let response: GuardianContent
}

struct GuardianContent: Codable {
    let results: [Article]
}

// Сама статья
struct Article: Codable {
    let id: String
    let webTitle: String       // Заголовок статьи
    let webUrl: String         // Ссылка на полную статью в браузере
    let fields: ArticleFields? // Дополнительные поля (картинка и описание)
    
    // Вычисляемые свойства для удобства
    var title: String { webTitle }
    
    var description: String {
        // Очищаем текст от HTML-тегов, так как Guardian присылает их в trailText
        return fields?.trailText?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression) ?? ""
    }
    
    var thumbnailURL: String? {
        return fields?.thumbnail
    }
}

// Поля, которые нужно запрашивать отдельно через параметр show-fields
struct ArticleFields: Codable {
    let thumbnail: String? // URL большой картинки
    let trailText: String? // Краткое подзаголовье/описание
}
