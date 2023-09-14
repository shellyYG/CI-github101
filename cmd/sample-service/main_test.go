package main

import "testing"

func TestTrimWords(t *testing.T) {
	tests := []struct{
		input string
		expected string
	}{
		{"ATB123", "123"},
		{"ATB", ""},
	}

	for _, tt := range tests {
		t.Run(tt.input, func(t *testing.T){
			actual := trimWords(tt.input)
			if actual != tt.expected {
				t.Errorf("trimWords(%q) = %q, want %q", tt.input, actual, tt.expected)
			}
		})
	}
}