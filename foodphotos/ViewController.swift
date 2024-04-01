import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let titleLabel = UILabel()
    let pickerView = UIPickerView()
    let fetchButton = UIButton(type: .system)
    let backButton = UIButton(type: .system)
    let imageView = UIImageView()
    let foodCategories = ["biryani", "burger", "butter-chicken", "dessert", "dosa", "idly", "pasta", "pizza", "rice", "samosa", "random"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the titleLabel
        titleLabel.text = "I'm hungry, show me photos of..."
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        // Setup the UIPickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        view.addSubview(pickerView)
        
        // Setup the fetchButton with filled style
        fetchButton.setTitle("Fetch Image", for: .normal)
        fetchButton.backgroundColor = .systemBlue
        fetchButton.setTitleColor(.white, for: .normal)
        fetchButton.layer.cornerRadius = 8
        fetchButton.addTarget(self, action: #selector(fetchImage), for: .touchUpInside)
        view.addSubview(fetchButton)
        
        // Setup the backButton with filled style
        backButton.setTitle("Back", for: .normal)
        backButton.backgroundColor = .systemGray
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.cornerRadius = 8
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        view.addSubview(backButton)
        
        // Setup the imageView
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        setupConstraints()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return foodCategories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return foodCategories[row]
    }

    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        fetchButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pickerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            pickerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            fetchButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
            fetchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.topAnchor.constraint(equalTo: fetchButton.bottomAnchor, constant: 20),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc func fetchImage() {
        let selectedCategoryIndex = pickerView.selectedRow(inComponent: 0)
        let selectedCategory = foodCategories[selectedCategoryIndex]
        let urlString = selectedCategory == "random" ? "https://foodish-api.com/api/" : "https://foodish-api.com/api/images/\(selectedCategory)"
        print("Fetching image from: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Network request failed: \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                  let imageUrlString = jsonObject["image"],
                  let imageUrl = URL(string: imageUrlString) else {
                print("Failed to parse response")
                return
            }

            DispatchQueue.main.async {
                self?.imageView.load(from: imageUrl)
            }
        }.resume()
    }
    
    @objc func goBack() {
        imageView.image = nil
    }
}

extension UIImageView {
    func load(from url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            } else {
                print("Failed to load image from URL: \(url)")
            }
        }
    }
}
