//
//  ActionSheetItemHandler.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2017-11-24.
//  Copyright © 2017 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This class is used as the data source and delegate for sheet
 items and button table views.
 */
open class ActionSheetItemHandler: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    
    // MARK: - Initialization
    
    public init(actionSheet: ActionSheet, itemType: ItemType) {
        self.actionSheet = actionSheet
        self.itemType = itemType
    }
    
    
    // MARK: - Types
    
    public enum ItemType {
        case items, buttons
    }
    
    
    // MARK: - Properties
    
    weak var actionSheet: ActionSheet?
    
    let itemType: ItemType
    
    var items: [MenuItem] {
        switch itemType {
        case .buttons: return actionSheet?.buttons ?? []
        case .items: return actionSheet?.items ?? []
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    open func item(at indexPath: IndexPath) -> MenuItem? {
        guard indexPath.section == 0 else { return nil }
        guard items.count > indexPath.row else { return nil }
        return items[indexPath.row]
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch itemType {
        case .items:
            var count = items.count
            if actionSheet?.headerView != nil {
                count += 1
            }
            
            return count
        case .buttons:
            return items.count
        }

    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var mutatedIndexPath = indexPath

        switch itemType {
        case .items:
            if let headerView = actionSheet?.headerView {
                if mutatedIndexPath.row == 0 {
                    headerView.backgroundColor = .clear
                    let cell = UITableViewCell()
                    cell.backgroundColor = .clear
                    cell.contentView.backgroundColor = .clear
                    cell.contentView.addSubview(headerView, fill: true)
                    cell.selectionStyle = .none
                    cell.separatorInset = .zero
                    return cell
                }
                
                mutatedIndexPath = IndexPath(row: mutatedIndexPath.row - 1, section: mutatedIndexPath.section)
            }
            
            fallthrough
        case .buttons:
            guard let item = self.item(at: mutatedIndexPath) else { return UITableViewCell(frame: .zero) }
            let cell = item.actionSheetCell(for: tableView)
            cell.refresh(with: item)
            return cell
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var mutatedIndexPath = indexPath
        switch itemType {
        case .items:
            if let headerView = actionSheet?.headerView {
                if indexPath.row == 0 {
                    return headerView.frame.height
                }
                
                mutatedIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            }
            
            fallthrough
        case .buttons:
            guard let item = self.item(at: mutatedIndexPath) else { return 0 }
            return CGFloat(item.actionSheetCellHeight)
        }
    }
    
    
    // MARK: - UITableViewDelegate
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var mutatedIndexPath = indexPath
        switch itemType {
        case .items:
            if let headerView = actionSheet?.headerView {
                mutatedIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            }
            
            fallthrough
        case .buttons:
            guard let item = self.item(at: mutatedIndexPath) else { return }
            tableView.deselectRow(at: mutatedIndexPath, animated: true)
            guard let sheet = actionSheet else { return }
            item.handleSelection(in: sheet.menu)
            sheet.handleTap(on: item)
        }
    }
}
