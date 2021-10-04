import SwiftUI

struct Course: Decodable, Identifiable {
    
    let id, numberOfLessons: Int
    let name, link, imageUrl: String
    
}

class ContentViewModel: ObservableObject {
    
    @Published var isFetching = false
    @Published var courses = [Course]()
    @Published var errorMessage = ""
    
    init() {
        //Fetch data
//
    }
    
    @MainActor
    func fetchData() async {
        let urlString = "https://api.letsbuildthatapp.com/jsondecodable/courses"
        
        guard let url = URL(string: urlString) else {
            print("error: can not fetch data")
            return
        }
        
        do {
            isFetching = true
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            
            if let resp = response as? HTTPURLResponse, resp.statusCode >= 300 {
                self.errorMessage = "failed to hit endpoint with bad status code"
            }
            //            print(data)
            
            self.courses = try JSONDecoder().decode([Course].self, from: data)
            isFetching = false
            //            print(courses)
        } catch {
            isFetching = false
            print("Failed to reac endpoint: \(error)")
        }
        
        
    }
}

struct ContentView: View {
    
    @ObservedObject var vm = ContentViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if vm.isFetching {
                    ProgressView()
                }
                
                VStack {
                    ForEach(vm.courses) { course in
                        let url = URL(string: course.imageUrl)
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        
                        Text(course.name)
                        
                    }
                }
                
                
                //                Text("Here is my scrollView")
            }
            .navigationTitle("Courses")
            .task {
                await vm.fetchData()
            }
            .navigationBarItems(trailing: refreshButton)
        }
    }
    private var refreshButton: some View {
        Button {
            Task.init {
                vm.courses.removeAll()
                await  vm.fetchData()
            }
        } label: {
            Text("Refresh")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
