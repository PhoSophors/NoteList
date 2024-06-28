import Foundation
import CoreData

class DataManager {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NoteListDataModel") // Ensure this matches your actual data model file name
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveFolder(name: String) {
        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Folder", in: context) else {
            fatalError("Failed to find entity description for Folder")
        }
        let folder = NSManagedObject(entity: entity, insertInto: context) as! Folder
        folder.folderName = name
        saveContext()
    }
    
    func fetchFolders() -> [Folder] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        do {
            let folders = try context.fetch(fetchRequest)
            return folders
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    func updateFolder(folder: Folder, newName: String) {
        let context = persistentContainer.viewContext
        folder.folderName = newName
        saveContext()
    }
    
    func deleteFolder(folder: Folder) {
        let context = persistentContainer.viewContext
        context.delete(folder)
        saveContext()
    }
}
