import { useState, useEffect, useRef } from 'react';

export const useVoiceRecognition = ({ 
  language, 
  onWakeWord, 
  onCommand, 
  wakeWords, 
  isAlwaysListening 
}) => {
  const [isListening, setIsListening] = useState(false);
  const recognitionRef = useRef(null);

  useEffect(() => {
    if (typeof window !== 'undefined' && 'webkitSpeechRecognition' in window) {
      recognitionRef.current = new window.webkitSpeechRecognition();
      recognitionRef.current.continuous = true;
      recognitionRef.current.interimResults = true;
      recognitionRef.current.lang = language === 'en' ? 'en-US' : 
                                   language === 'ru' ? 'ru-RU' : 
                                   language === 'az' ? 'az-AZ' : 'it-IT';

      recognitionRef.current.onstart = () => {
        setIsListening(true);
      };

      recognitionRef.current.onresult = (event) => {
        let finalTranscript = '';
        
        for (let i = event.resultIndex; i < event.results.length; i++) {
          if (event.results[i].isFinal) {
            finalTranscript += event.results[i][0].transcript;
          }
        }

        const transcript = finalTranscript.toLowerCase().trim();
        
        if (transcript && wakeWords.some(word => transcript.includes(word.toLowerCase()))) {
          onWakeWord();
        } else if (transcript) {
          onCommand(finalTranscript);
        }
      };

      recognitionRef.current.onend = () => {
        setIsListening(false);
        if (isAlwaysListening && recognitionRef.current) {
          // Add a small delay to allow the recognition engine to fully stop
          setTimeout(() => {
            if (recognitionRef.current && !recognitionRef.current.recognizing) {
              try {
                recognitionRef.current.start();
              } catch (error) {
                console.error('Error restarting recognition:', error);
              }
            }
          }, 100);
        }
      };

      recognitionRef.current.onerror = (event) => {
        console.error('Speech recognition error:', event.error);
        if (event.error !== 'no-speech' && isAlwaysListening) {
          setTimeout(() => {
            if (recognitionRef.current && !recognitionRef.current.recognizing) {
              try {
                recognitionRef.current.start();
              } catch (e) {
                console.error('Error restarting recognition on error:', e);
              }
            }
          }, 1000);
        } else {
          setIsListening(false);
        }
      };
    }

    return () => {
      if (recognitionRef.current) {
        recognitionRef.current.abort();
      }
    };
  }, [language, onWakeWord, onCommand, wakeWords, isAlwaysListening]);

  useEffect(() => {
    if (recognitionRef.current) {
      if (isAlwaysListening && !recognitionRef.current.recognizing) {
        try {
          recognitionRef.current.start();
        } catch (error) {
          console.error('Error starting recognition:', error);
        }
      } else if (!isAlwaysListening && recognitionRef.current.recognizing) {
        recognitionRef.current.stop();
      }
    }
  }, [isAlwaysListening]); // Removed isListening from dependency array

  const startListening = () => {
    if (recognitionRef.current && !recognitionRef.current.recognizing) {
      try {
        recognitionRef.current.start();
      } catch (error) {
        console.error('Error starting recognition manually:', error);
      }
    }
  };

  const stopListening = () => {
    if (recognitionRef.current && recognitionRef.current.recognizing) {
      recognitionRef.current.stop();
    }
  };

  return { isListening, startListening, stopListening };
};