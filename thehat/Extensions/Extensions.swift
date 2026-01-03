//
//  Extensions.swift
//  thehat
//
//  Created by Eugene Yurtaev on 24/05/15.
//  Copyright (c) 2015 dpfbop. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func setNavigationBarTitleWithCustomFont(title: String) {
        let size = UIFont(name: "Avenir Next", size: 18)?.sizeOfString(string: title, constrainedToWidth: 200)
        let label = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size!))
        label.text = title
        label.font = UIFont(name: "Avenir Next", size: 18)
        self.navigationItem.titleView = label
    }
}


extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a: Int)
    {
        let newRed   = CGFloat(Double(r) / 255.0)
        let newGreen = CGFloat(Double(g) / 255.0)
        let newBlue  = CGFloat(Double(b) / 255.0)
        let newAlpha = CGFloat(Double(a) / 100.0)
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }
}

extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int.random(in: i..<count)
            if i != j {
                self.swapAt(i, j)
            }
        }
    }
}

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return (string as String).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                               options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                               attributes: [NSAttributedString.Key.font: self],
            context: nil).size
    }
}

class RandomNames {
    static let russianNames: [String] = ["Одуванчик", "Мечтатель", "Няшка", "Лошадка", "Цветочек", "Рыбка", "Огонь", "Вода", "Хорек", "Принцесса", "Мумий Тролль", "Шерлок", "Котик", "Робин Гуд", "Мориарти", "Халк", "Рапунцель", "Ангел", "Люцифер", "Джеймс Бонд", "Хипстер", "Гарри Поттер", "Гермиона", "Рон Уизли", "Волан-де-Морт", "Дамблдор", "Хоббит", "Эльф", "Голум", "Гендальф", "Жираф", "Аватар", "Доктор Хаус", "Джон Сноу", "Дейенерис", "Винни-Пух", "Сфинкс", "Кузнечик", "Лорд", "Господин", "Шакал", "Симба", "Тимон", "Пумба", "Цезарь", "Клеопатра", "Колобок"]
    
    static let englishNames: [String] = ["Flower", "Beauty", "Fire", "Batman", "Spiderman", "Sherlock", "Princess", "Angel", "Dreamer", "Moriarty", "Hulk", "Rapunzel", "Angel", "Lucifer", "James Bond", "Hipster", "Harry Potter", "Hermione", "Ron Weasley", "Volan-de-Mort", "Dumbledore", "Hobbit", "Elf", "Gollum", "Gandalf", "Giraffe", "Avatar", "Brad Pitt", "Dr. House", "John Snow", "Daenerys", "Winnie the Pooh", "Sphinx", "Lord", "Jackal", "Simba", "Timon", "Pumbaa"]
    
    static var last: [Int] = []
    
    static func getRandomName() -> String {
        let names = Locale.preferredLanguages[0].contains("ru") ? russianNames : englishNames

        var new = Int.random(in: 0..<names.count)
        while last.contains(new) {
            new = Int.random(in: 0..<names.count)
        }
        last.append(new)
        if last.count > 10 {
            last = Array(last.dropFirst())
        }
        return names[new]
    }
}


extension UIViewController {
    func isIpad() -> Bool {
        if self.traitCollection.userInterfaceIdiom == .phone {
            return false
        } else {
            return true
        }
    }
}
