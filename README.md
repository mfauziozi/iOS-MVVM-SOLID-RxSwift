# iOS-MVVM-SOLID-RxSwift

--- 

## iOS MVVM Architecture with RxSwift, UIKit, and SOLID Principles

This project is an **iOS application** built using **MVVM architecture**, **RxSwift** for reactive programming, and **UIKit** for UI components. It follows **SOLID principles** to ensure maintainable, scalable, and testable code.

---

## 📖 Overview

- **MVVM (Model–View–ViewModel)**: Separates responsibilities between UI, data handling, and business logic.
- **RxSwift**: Simplifies asynchronous programming using reactive streams.
- **UIKit**: Provides the foundation for building rich and interactive UIs.
- **SOLID Principles**: Ensures clean architecture, easy maintenance, and scalability.

---

## 🏗 Architecture

The project is structured into clear, modular layers:

### MVVM Flow
1. **Model**: Represents the data and business logic.
2. **ViewModel**: Observes data changes and prepares data for the view.
3. **View**: Renders the UI and binds to the ViewModel using RxSwift.

---

## 🔗 Reactive Programming with RxSwift

- **Observables**: Streams of data that can be subscribed to.
- **Binders**: Connect ViewModel outputs directly to the UI.
- **Schedulers**: Control where the code executes (Main thread for UI, background for heavy tasks).
