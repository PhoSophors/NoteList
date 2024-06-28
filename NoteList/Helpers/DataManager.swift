import Foundation
import CoreData

class DataManager {

    static let shared = DataManager()

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NoteListDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Failed to load Core Data stack: \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Failed to save Core Data context: \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Folder operations

    func saveFolder(name: String) {
        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Folder", in: context) else {
            fatalError("Failed to find entity description for Folder")
        }
        let folder = Folder(entity: entity, insertInto: context)
        folder.folderName = name
        saveContext()
    }

    func fetchFolders() -> [Folder] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        do {
            let folders = try context.fetch(fetchRequest)
            return folders
        } catch {
            print("Failed to fetch folders: \(error)")
            return []
        }
    }

    func updateFolder(folder: Folder, newName: String) {
        folder.folderName = newName
        saveContext()
    }

    func deleteFolder(folder: Folder) {
        let context = persistentContainer.viewContext
        context.delete(folder)
        saveContext()
    }

    // MARK: - Note operations

    func saveNote(title: String, description: String, folder: Folder) {
        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: context) else {
            fatalError("Failed to find entity description for Note")
        }
        let note = Note(entity: entity, insertInto: context)
        note.noteTitle = title
        note.noteDescription = description
        note.folder = folder
        saveContext()
    }

    // Add more methods as needed for note operations

}
