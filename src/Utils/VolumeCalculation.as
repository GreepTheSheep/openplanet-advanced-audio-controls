float CalculateNewDb(const float &in dB, const float &in percent) {
    return dB + 20 * Math::Log10(percent / 100);
}