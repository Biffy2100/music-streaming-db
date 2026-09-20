/**
 * Audio Player Controller with Web Audio API tone synthesis and full playback state.
 */

class AudioPlayer {
  constructor() {
    this.currentTrack = null;
    this.isPlaying = false;
    this.currentTime = 0;
    this.duration = 240;
    this.volume = 0.7;
    this.isMuted = false;
    this.isShuffle = false;
    this.isLoop = false;
    this.queue = [];
    this.queueIndex = -1;

    // Web Audio synthesizer components
    this.audioCtx = null;
    this.masterGain = null;
    this.synthInterval = null;
    this.tickerInterval = null;

    this.initElements();
    this.bindEvents();
  }

  initElements() {
    this.elPlayBtn = document.getElementById('player-play-btn');
    this.elPlayIcon = document.getElementById('play-btn-icon');
    this.elPrevBtn = document.getElementById('player-prev-btn');
    this.elNextBtn = document.getElementById('player-next-btn');
    this.elShuffleBtn = document.getElementById('player-shuffle-btn');
    this.elLoopBtn = document.getElementById('player-loop-btn');

    this.elTitle = document.getElementById('player-title');
    this.elArtist = document.getElementById('player-artist');
    this.elTimeElapsed = document.getElementById('player-time-elapsed');
    this.elTimeTotal = document.getElementById('player-time-total');
    this.elProgressFill = document.getElementById('progress-bar-fill');
    this.elProgressContainer = document.getElementById('progress-bar-container');
    this.elVolumeSlider = document.getElementById('volume-slider');
    this.elVolumeIcon = document.getElementById('btn-volume-icon');
    this.elEqualizer = document.getElementById('equalizer-bars');
  }

  bindEvents() {
    if (this.elPlayBtn) {
      this.elPlayBtn.addEventListener('click', () => this.togglePlay());
    }
    if (this.elPrevBtn) {
      this.elPrevBtn.addEventListener('click', () => this.prev());
    }
    if (this.elNextBtn) {
      this.elNextBtn.addEventListener('click', () => this.next());
    }
    if (this.elShuffleBtn) {
      this.elShuffleBtn.addEventListener('click', () => {
        this.isShuffle = !this.isShuffle;
        this.elShuffleBtn.style.color = this.isShuffle ? 'var(--accent-green)' : 'var(--text-muted)';
        app.showToast(this.isShuffle ? 'Shuffle enabled' : 'Shuffle disabled');
      });
    }
    if (this.elLoopBtn) {
      this.elLoopBtn.addEventListener('click', () => {
        this.isLoop = !this.isLoop;
        this.elLoopBtn.style.color = this.isLoop ? 'var(--accent-green)' : 'var(--text-muted)';
        app.showToast(this.isLoop ? 'Repeat track enabled' : 'Repeat track disabled');
      });
    }
    if (this.elProgressContainer) {
      this.elProgressContainer.addEventListener('click', (e) => {
        const rect = this.elProgressContainer.getBoundingClientRect();
        const clickRatio = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
        this.seekTo(clickRatio * this.duration);
      });
    }
    if (this.elVolumeSlider) {
      this.elVolumeSlider.addEventListener('input', (e) => {
        this.setVolume(parseFloat(e.target.value));
      });
    }
    if (this.elVolumeIcon) {
      this.elVolumeIcon.addEventListener('click', () => {
        this.isMuted = !this.isMuted;
        if (this.masterGain) {
          this.masterGain.gain.value = this.isMuted ? 0 : this.volume;
        }
        this.elVolumeSlider.value = this.isMuted ? 0 : this.volume;
      });
    }
  }

  initWebAudio() {
    if (!this.audioCtx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      this.audioCtx = new AudioContext();
      this.masterGain = this.audioCtx.createGain();
      this.masterGain.gain.value = this.volume;
      this.masterGain.connect(this.audioCtx.destination);
    }
    if (this.audioCtx.state === 'suspended') {
      this.audioCtx.resume();
    }
  }

  playMelodyTone(freq, type = 'sine', duration = 0.35) {
    if (!this.audioCtx || this.isMuted) return;
    try {
      const osc = this.audioCtx.createOscillator();
      const noteGain = this.audioCtx.createGain();

      osc.type = type;
      osc.frequency.setValueAtTime(freq, this.audioCtx.currentTime);

      noteGain.gain.setValueAtTime(0.12, this.audioCtx.currentTime);
      noteGain.gain.exponentialRampToValueAtTime(0.001, this.audioCtx.currentTime + duration);

      osc.connect(noteGain);
      noteGain.connect(this.masterGain);

      osc.start();
      osc.stop(this.audioCtx.currentTime + duration);
    } catch (e) {
      // AudioContext fallback
    }
  }

  startSynthesizer() {
    this.stopSynthesizer();
    this.initWebAudio();

    // Scales based on song id for distinct melodic flavor
    const scales = [
      [261.63, 293.66, 329.63, 392.00, 440.00], // C Major Pentatonic
      [220.00, 261.63, 293.66, 329.63, 392.00], // A Minor Pentatonic
      [293.66, 329.63, 369.99, 440.00, 493.88], // D Major
      [196.00, 220.00, 246.94, 293.66, 329.63]  // G Major
    ];

    const currentScale = scales[(this.currentTrack ? this.currentTrack.Song_ID : 1) % scales.length];
    let noteIndex = 0;

    this.synthInterval = setInterval(() => {
      if (!this.isPlaying) return;
      const freq = currentScale[noteIndex % currentScale.length];
      const octaves = [1, 1, 1.5, 0.5];
      const mult = octaves[Math.floor(Math.random() * octaves.length)];
      this.playMelodyTone(freq * mult, (noteIndex % 2 === 0) ? 'triangle' : 'sine', 0.4);
      noteIndex++;
    }, 480);
  }

  stopSynthesizer() {
    if (this.synthInterval) {
      clearInterval(this.synthInterval);
      this.synthInterval = null;
    }
  }

  setTrack(track, queue = []) {
    this.currentTrack = track;
    this.duration = track.Duration || 240;
    this.currentTime = 0;

    if (queue.length > 0) {
      this.queue = queue;
      this.queueIndex = this.queue.findIndex(t => t.Song_ID === track.Song_ID);
    }

    if (this.elTitle) this.elTitle.textContent = track.Title || 'Unknown Track';
    if (this.elArtist) {
      const art = track.Artist_Name || 'Unknown Artist';
      const alb = track.Album_Name ? ` • ${track.Album_Name}` : '';
      this.elArtist.textContent = `${art}${alb}`;
    }
    if (this.elTimeTotal) this.elTimeTotal.textContent = this.formatTime(this.duration);

    this.updateProgressUI();
    this.play();

    // Log play to backend
    if (window.app && app.activeUserId) {
      fetch('/api/history', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_id: app.activeUserId,
          song_id: track.Song_ID
        })
      }).then(() => {
        if (app.currentView === 'history' || app.currentView === 'home') {
          app.loadHistory();
        }
      }).catch(() => {});
    }
  }

  play() {
    this.isPlaying = true;
    if (this.elEqualizer) this.elEqualizer.classList.add('active');
    this.updatePlayBtnUI();
    this.startSynthesizer();

    if (this.tickerInterval) clearInterval(this.tickerInterval);
    this.tickerInterval = setInterval(() => {
      if (this.currentTime >= this.duration) {
        if (this.isLoop) {
          this.seekTo(0);
        } else {
          this.next();
        }
      } else {
        this.currentTime += 1;
        this.updateProgressUI();
      }
    }, 1000);

    // Highlight row in active tables
    document.querySelectorAll('.data-table tbody tr').forEach(tr => {
      tr.classList.remove('playing');
      if (tr.dataset.songId == (this.currentTrack ? this.currentTrack.Song_ID : null)) {
        tr.classList.add('playing');
      }
    });
  }

  pause() {
    this.isPlaying = false;
    if (this.elEqualizer) this.elEqualizer.classList.remove('active');
    this.updatePlayBtnUI();
    this.stopSynthesizer();
    if (this.tickerInterval) {
      clearInterval(this.tickerInterval);
      this.tickerInterval = null;
    }
  }

  togglePlay() {
    if (!this.currentTrack) {
      if (this.queue.length > 0) {
        this.setTrack(this.queue[0], this.queue);
      } else if (window.app && app.songs.length > 0) {
        this.setTrack(app.songs[0], app.songs);
      }
      return;
    }
    if (this.isPlaying) {
      this.pause();
    } else {
      this.play();
    }
  }

  next() {
    if (this.queue.length === 0) return;
    if (this.isShuffle) {
      this.queueIndex = Math.floor(Math.random() * this.queue.length);
    } else {
      this.queueIndex = (this.queueIndex + 1) % this.queue.length;
    }
    this.setTrack(this.queue[this.queueIndex], this.queue);
  }

  prev() {
    if (this.queue.length === 0) return;
    if (this.currentTime > 4) {
      this.seekTo(0);
      return;
    }
    this.queueIndex = (this.queueIndex - 1 + this.queue.length) % this.queue.length;
    this.setTrack(this.queue[this.queueIndex], this.queue);
  }

  seekTo(seconds) {
    this.currentTime = Math.max(0, Math.min(seconds, this.duration));
    this.updateProgressUI();
  }

  setVolume(vol) {
    this.volume = vol;
    this.isMuted = false;
    if (this.masterGain) {
      this.masterGain.gain.value = vol;
    }
  }

  updateProgressUI() {
    if (this.elTimeElapsed) {
      this.elTimeElapsed.textContent = this.formatTime(this.currentTime);
    }
    if (this.elProgressFill) {
      const pct = (this.currentTime / Math.max(1, this.duration)) * 100;
      this.elProgressFill.style.width = `${pct}%`;
    }
  }

  updatePlayBtnUI() {
    if (this.elPlayBtn) {
      // Standard player behavior:
      // When playing: show PAUSE (click to pause)
      // When paused: show PLAY (click to play)
      const icon = this.isPlaying ? 'pause' : 'play';
      this.elPlayBtn.innerHTML = `<i data-lucide="${icon}"></i>`;
      this.elPlayBtn.title = this.isPlaying ? 'Pause (Click to pause)' : 'Play (Click to listen)';
      if (this.isPlaying) {
        this.elPlayBtn.style.backgroundColor = 'var(--accent-green)';
        this.elPlayBtn.style.color = '#000';
        this.elPlayBtn.style.boxShadow = '0 0 16px var(--accent-green-glow)';
      } else {
        this.elPlayBtn.style.backgroundColor = '#fff';
        this.elPlayBtn.style.color = '#000';
        this.elPlayBtn.style.boxShadow = 'none';
      }
    }

    // Synchronize play/pause icons on active and inactive song rows
    document.querySelectorAll('.data-table tbody tr').forEach(tr => {
      const songId = parseInt(tr.dataset.songId);
      const firstBtn = tr.querySelector('td:first-child button');
      if (this.currentTrack && songId === this.currentTrack.Song_ID) {
        if (this.isPlaying) {
          tr.classList.add('playing');
        } else {
          tr.classList.remove('playing');
        }
        if (firstBtn) {
          firstBtn.innerHTML = `<i data-lucide="${this.isPlaying ? 'pause' : 'play'}" style="width: 18px; height: 18px; color: var(--accent-green);"></i>`;
        }
      } else {
        tr.classList.remove('playing');
        if (firstBtn) {
          firstBtn.innerHTML = `<i data-lucide="play" style="width: 18px; height: 18px;"></i>`;
        }
      }
    });

    if (window.lucide) {
      lucide.createIcons();
    }
  }

  formatTime(seconds) {
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${m}:${s < 10 ? '0' : ''}${s}`;
  }
}

// Global player instance
window.player = new AudioPlayer();
