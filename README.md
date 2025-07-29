# Flutter Transaction Flow Animation

A highly customizable and animated Flutter widget to visualize multi-step transaction processes with dynamic loading, propagation, and distinct success, failure, and pending states.

## ✨ Key Features

* **Layered Animations:** Smooth transitions and complex choreography between different UI elements.
* **Custom Progress Indicators:** Unique step indicators with a "break-out" bubble-like effect (WIP/seeking feedback!).
* **Propagation Effect:** Visual progression of transaction status across steps, enhancing user feedback.
* **Dynamic State Management:** Adapts UI based on `Success`, `Failure`, and `Pending` transaction results.
* **CustomPaint Implementation:** Utilizes `CustomPainter` for drawing custom shapes and animations (e.g., the dotted line and bubble indicators).
* **Intuitive User Feedback:** Clear titles, subtitles, and status indicators guide the user.

## 📸 Screenshots

![Animated Transaction Flow Demo](https://x.com/trillionclues/status/1950146796941942793)

## Technologies Used

* **Flutter:** The UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
* **Dart:** The programming language used by Flutter.
* **AnimationController:** For precise control over animation durations and curves.
* **CustomPainter:** For drawing bespoke shapes and effects on the canvas.
* **TickerProviderStateMixin:** For providing tickers to `AnimationController`s.

## Challenges & Future Improvements

This project was a great learning experience in Flutter animations. Some areas I'm still exploring and would welcome contributions/feedback on include:

* **Bubble-like Effect:** Further refining the custom `CustomPainter` to achieve a more organic, truly "bubble-like" or fluid shape for the active/completed step indicators, including a more pronounced "break-out" point.
* **Completion Splash/Blur:** Implementing a more sophisticated visual flourish (e.g., a blur, glow, or particle splash) when the transaction successfully completes.
* **Performance Optimization:** Continually looking for ways to optimize animation performance for smoother rendering on various devices.

## 🚀 How to Run

To run this project locally, make sure you have Flutter installed.

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
    cd your-repo-name
    ```
2.  **Get dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the app:**
    ```bash
    flutter run
    ```

## License

This project is licensed under the MIT License.