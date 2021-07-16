import Lottie

class ContainerView: RCTView {
    private var speed: CGFloat = 0.0
    private var progress: CGFloat = 0.0
    private var loop: LottieLoopMode = .playOnce
    private var sourceJson: String = ""
    private var resizeMode: String = ""
    private var sourceName: String = ""
    private var colorFilters: [NSDictionary] = []
    private var progressTimer: Timer?
    
    @objc var onAnimationFinish: RCTBubblingEventBlock?
    @objc var onAnimationProgressCallback: RCTBubblingEventBlock?
    
    var animationView: AnimationView?
    

    @objc func setSpeed(_ newSpeed: CGFloat) {
        speed = newSpeed

        if (newSpeed != 0.0) {
            animationView?.animationSpeed = newSpeed
            if (!(animationView?.isAnimationPlaying ?? true)) {
                animationView?.play()
            }
        } else if (animationView?.isAnimationPlaying ?? false) {
            animationView?.pause()
        }
    }

    @objc func setProgress(_ newProgress: CGFloat) {
        progress = newProgress
        animationView?.currentProgress = progress
    }

    override func reactSetFrame(_ frame: CGRect) {
        super.reactSetFrame(frame)
        animationView?.reactSetFrame(frame)
    }

    @objc func setLoop(_ isLooping: Bool) {
        loop = isLooping ? .loop : .playOnce
        animationView?.loopMode = loop
    }

    @objc func setSourceJson(_ newSourceJson: String) {
        sourceJson = newSourceJson

        guard let data = sourceJson.data(using: String.Encoding.utf8),
        let animation = try? JSONDecoder().decode(Animation.self, from: data) else {
            if (RCT_DEBUG == 1) {
                print("Unable to create the lottie animation object from the JSON source")
            }
            return
        }

        let starAnimationView = AnimationView()
        starAnimationView.animation = animation
        replaceAnimationView(next: starAnimationView)
    }

    @objc func setSourceName(_ newSourceName: String) {
        if (newSourceName == sourceName) {
          return
        }
        sourceName = newSourceName
        let url = URL(fileURLWithPath: sourceName)

        guard let data = try? Data(contentsOf: url),
              let animation = try? JSONDecoder().decode(Animation.self, from: data) else {
            return
        }
        
        let starAnimationView = AnimationView()
        starAnimationView.animation = animation
        replaceAnimationView(next: starAnimationView)
    }

    @objc func setResizeMode(_ resizeMode: String) {
        switch (resizeMode) {
        case "cover":
            animationView?.contentMode = .scaleAspectFill
        case "contain":
            animationView?.contentMode = .scaleAspectFit
        case "center":
            animationView?.contentMode = .center
        default: break
        }
    }

    @objc func setColorFilters(_ newColorFilters: [NSDictionary]) {
        colorFilters = newColorFilters

        if (colorFilters.count > 0) {
            for filter in colorFilters {
                let keypath: String = "\(filter.value(forKey: "keypath") as! String).**.Color"
                let fillKeypath = AnimationKeypath(keypath: keypath)
                let colorFilterValueProvider = ColorValueProvider(hexStringToColor(hex: filter.value(forKey: "color") as! String))
                animationView?.setValueProvider(colorFilterValueProvider, keypath: fillKeypath)
            }
        }
    }

    func play(fromFrame: AnimationFrameTime? = nil, toFrame: AnimationFrameTime, completion: LottieCompletionBlock? = nil) {
        animationView?.backgroundBehavior = .pauseAndRestore
        animationView?.play(fromFrame: fromFrame, toFrame: toFrame, loopMode: self.loop, completion: completion);
    }
    
    func playProgress(progress: Float, completion: LottieCompletionBlock? = nil) {
        animationView?.play(fromProgress: AnimationProgressTime(progress), toProgress: 1.0, loopMode: animationView?.loopMode, completion: completion)
    }

    func play(completion: LottieCompletionBlock? = nil) {
        animationView?.backgroundBehavior = .pauseAndRestore
        animationView?.play(completion: completion)
    }

    func reset() {
        animationView?.currentProgress = 0;
        animationView?.pause()
    }

    func pause() {
        animationView?.pause()
    }

    func resume() {
        play()
    }

    // MARK: Private

    func replaceAnimationView(next: AnimationView) {
        animationView?.removeFromSuperview()

        let contentMode = animationView?.contentMode ?? .scaleAspectFit
        animationView = next
        addSubview(next)
        animationView?.contentMode = contentMode
        animationView?.reactSetFrame(frame)
        applyProperties()
    }

    func applyProperties() {
        animationView?.currentProgress = progress
        animationView?.animationSpeed = speed
        animationView?.loopMode = loop
        setColorFilters(colorFilters)
    }
    
    
    func startProgressTimer() {
        stopProgressTimer()
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            if let view = self?.animationView, view.isAnimationPlaying {
                self?.onAnimationProgressCallback?(["progress": (self?.animationView?.realtimeAnimationProgress) as Any])
            }
        }
    }
    
    func stopProgressTimer() {
        if let timer = progressTimer {
            timer.invalidate()
            progressTimer = nil
        }
    }
}
