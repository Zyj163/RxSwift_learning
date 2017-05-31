//
//  TableViewController.swift
//  RxSwift学习
//
//  Created by ddn on 2017/5/31.
//  Copyright © 2017年 张永俊. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TableViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	
	fileprivate lazy var bag = DisposeBag()
	let vm = TableViewModel()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		
		vm.datas.asObservable().bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) {row, d, cell in
			cell.textLabel?.text = d
		}.addDisposableTo(bag)
		
		tableView.rx.itemSelected.subscribe(onNext: {[weak self] (indexPath) in
			self?.tableView.deselectRow(at: indexPath, animated: true)
		}).addDisposableTo(bag)
		
		tableView.rx.modelSelected(String.self).subscribe(onNext: { (t) in
			print(t)
		}).addDisposableTo(bag)
    }

}
