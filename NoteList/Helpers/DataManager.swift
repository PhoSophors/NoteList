import Foundation
import CoreData

class DataManager {

    static let shared = DataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NoteListDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - SAVE CONTEXT
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

    // MARK: - SAVE FOLDER TO CORE DATA
    func saveFolder(name: String) {
        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Folder", in: context) else {
            fatalError("Failed to find entity description for Folder")
        }
        let folder = NSManagedObject(entity: entity, insertInto: context) as! Folder
        folder.folderName = name
        saveContext()
    }

    // MARK: - SAVE NOTE TO CORE DATA
    func saveNote(title: String, descriptions: String, folder: Folder) {
        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: context) else {
            fatalError("Failed to find entity description for Note")
        }
        let note = NSManagedObject(entity: entity, insertInto: context) as! Note
        note.noteTitle = title
        note.noteDescription = descriptions
        note.folder = folder
        saveContext()
    }

    // MARK: - FETCH FOLDER FROM CORE DATA
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

    // MARK: - UPDATE FOLDER FROM CORE DATA
    func updateFolder(folder: Folder, newName: String) {
        let context = persistentContainer.viewContext
        folder.folderName = newName
        saveContext()
    }

    // MARK: - DELETE FOLDER FROM CORE DATA
    func deleteFolder(folder: Folder) {
        let context = persistentContainer.viewContext
        context.delete(folder)
        saveContext()
    }
}
