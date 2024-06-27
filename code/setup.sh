echo "Setting up Ollama"
systemctl start ollama
echo "Pulling model llama3"
ollama pull llama3
ollama list
