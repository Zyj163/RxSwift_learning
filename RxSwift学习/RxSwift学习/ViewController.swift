//
//  ViewController.swift
//  RxSwift学习
//
//  Created by ddn on 2017/5/31.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
	@IBOutlet weak var btn1: UIButton!
	@IBOutlet weak var btn2: UIButton!
	
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var textField: UITextField!
	
	@IBOutlet weak var scrollView: UIScrollView!
	
	fileprivate lazy var bag: DisposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		//监听点击
		btn1.rx.tap.subscribe {(event: Event<()>) in
			print("发生了点击")
			print(event)
		}.addDisposableTo(bag)
		
		//监听文字改变
//		textField.rx.text.subscribe {(event: Event<String?>) in
//			print("文字发生变化")
//			print(event)
//		}.addDisposableTo(bag)
		textField.rx.text
			.subscribe(onNext: { (t: String?) in
				print("文字发生变化")
				print(t!)
			}).addDisposableTo(bag)
		
		//将textField的文字显示在label上
		textField.rx.text
			.bind(to: label.rx.text)
			.addDisposableTo(bag)
		
		//KVO
		label.rx
			.observe(String.self, "text")
			.subscribe(onNext: { (t: String?) in
				print("label文字发生变化")
			}).addDisposableTo(bag)
		
		//UIScrollView
		scrollView.backgroundColor = .red
		scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: scrollView.bounds.height*2)
		scrollView.rx.contentOffset
			.subscribe(onNext: { (o: CGPoint) in
				print(o)
			}).addDisposableTo(bag)
		
		
		//常见操作
		//never 永远不执行(不知道干嘛用的)
		let neverO = Observable<String>.never()
		neverO.subscribe { (e: Event<String>) in
			print(e)
		}.addDisposableTo(bag)
		
		//empty  只能发出complete事件
		let emptyO = Observable<String>.empty()
		emptyO.subscribe { (e: Event<String>) in
			print(e)
		}.addDisposableTo(bag)
		
		//just  产生一个指定事件，而且可以正常结束
		let justO = Observable.just("just")
		justO.subscribe { (e: Event<String>) in
			print(e)
		}.addDisposableTo(bag)
		
		//of   可以产生多个事件信号
		let ofO = Observable.of("a", "b")
		ofO.subscribe { (e: Event<String>) in
			print(e)
		}.addDisposableTo(bag)
		
		//from 从数组中创建sequence
		let fromO = Observable.from([1, 2])
		fromO.subscribe { (e: Event<Int>) in
			print(e)
		}.addDisposableTo(bag)
		
		//create   自定义Observerable
		let createO = createObserver()
		createO.subscribe { (e: Event<Any>) in
			print(e)
		}.addDisposableTo(bag)
		
		//range
		let rangeO = Observable.range(start: 1, count: 10)
		rangeO.subscribe { (e: Event<Int>) in
			print(e)
		}.addDisposableTo(bag)
		
		//repeatElement   take指定次数，不指定会无限打印
		let repeatO = Observable.repeatElement("hello")
		repeatO.take(5).subscribe { (e: Event<String>) in
			print(e)
		}.addDisposableTo(bag)
		
		
		//Subjects  既是observer，也是observerable
		//PublishSubject  当你订阅PublishSubject的时候，你只能接收到订阅他之后发生的事件
		let publishSubject = PublishSubject<String>()
		
		publishSubject.onNext("publishSubject before")
		
		publishSubject.subscribe { (e: Event<String>) in
			print(e)
		}.addDisposableTo(bag)
		
		publishSubject.onNext("publishSubject after")
		
		//ReplaySubject   当你订阅ReplaySubject的时候，你可以接收到订阅他之后的事件，页可以接收订阅他之前的事件，接收几个事件取决与bufferSize的大小
		let replaySubject = ReplaySubject<String>.create(bufferSize: 2)
//		ReplaySubject<String>.createUnbounded()//无限大
		
		replaySubject.onNext("a")
		
		replaySubject.subscribe { (e: Event<String>) in
			print(e)
		}.addDisposableTo(bag)
		
		replaySubject.onNext("b")
		replaySubject.onNext("c")
		
		//BehaviorSubject   会接收到订阅之前的最后一个事件
		let behaviorSubject = BehaviorSubject(value: "a")
		behaviorSubject.onNext("b")
		behaviorSubject.onNext("c")
		behaviorSubject.onNext("d")
		
		behaviorSubject.subscribe { (e: Event<String>) in
			print(e)
		}.addDisposableTo(bag)
		
		behaviorSubject.onNext("e")
		behaviorSubject.onNext("f")
		
		//Variable  相当于对BehaviorSubject进行装箱，如果想将Variable当成Observable，让订阅者订阅时，需要asObservable转成observable，如果Variable想发出事件，直接修改value即可，当事件结束时，会自动发出complete事件
		let varibale = Variable("a")
		varibale.asObservable().subscribe { (e: Event<String>) in
			print(e)
		}.addDisposableTo(bag)
		varibale.value = "b"
		
		
		//变换操作
		//map
		Observable.of(1, 2, 3).map { $0 * $0 }.subscribe { print($0) }.addDisposableTo(bag)
		
		//flatMap
		struct Student {
			var score: Variable<Double>
		}
		let stu = Student(score: Variable(80))
		let stuVariable = Variable(stu)
		//全都订阅
		stuVariable.asObservable().flatMap { (stu: Student) -> Observable<Double> in
			return stu.score.asObservable()
		}.subscribe { print($0) }.addDisposableTo(bag)
		//只订阅第一个stu
		stuVariable.asObservable().flatMapFirst { (stu: Student) -> Observable<Double> in
			return stu.score.asObservable()
			}.subscribe { print($0) }.addDisposableTo(bag)
		//只订阅最新的一个stu
		stuVariable.asObservable().flatMapLatest { (stu: Student) -> Observable<Double> in
			return stu.score.asObservable()
		}.subscribe { print($0) }.addDisposableTo(bag)
		stu.score.value = 10
		let stu2 = Student(score: Variable(30))
		stuVariable.value = stu2
		stu2.score.value = 40
	}

}

extension ViewController {
	fileprivate func createObserver() -> Observable<Any> {
		return Observable.create({ (observer: AnyObserver<Any>) -> Disposable in
			observer.onNext("a")
			observer.onNext("b")
			observer.onCompleted()
			
			return Disposables.create()
		})
	}
}

//extension Reactive where Base: UITextField {
//	var inputEnable: UIBindingObserver<Base, Result> {
//		return UIBindingObserver(UIElement: base, binding: { (textField, result) in
//			textField.isEnable = result.isValid
//		})
//	}
//}

















