#include <Rcpp.h>

#include <iostream>
#include <fstream>
#include <bitset>

using namespace Rcpp;

#define MAX_BUFFER_SIZE (1024 * 1000)
#define ESTIMATED_RECS 1000

// Function to read .sl2 files originally from the "arabia" R-package by Bob Rudis (<https://github.com/hrbrmstr/arabia>)
// Modified by Kenneth Thorø Martinsen
//'
//' @md
//' @param path to '.sl2' file
//' @return data.frame
//' @export
// [[Rcpp::export]]

DataFrame read_sl2_cpp(std::string path) {
  
  std::string full_path = std::string(R_ExpandFileName(path.c_str()));
  
  char buffer[MAX_BUFFER_SIZE];
  std::vector < long > PositionOfFirstByteV; PositionOfFirstByteV.reserve(ESTIMATED_RECS);
  std::vector < long > TotalLengthV; TotalLengthV.reserve(ESTIMATED_RECS);
  std::vector < long > SurveyTypeV; SurveyTypeV.reserve(ESTIMATED_RECS);
  std::vector < float > MinRangeV; MinRangeV.reserve(ESTIMATED_RECS);
  std::vector < float > MaxRangeV; MaxRangeV.reserve(ESTIMATED_RECS);
  std::vector < float > WaterDepthV; WaterDepthV.reserve(ESTIMATED_RECS);
  //std::vector < long > FrequencyV; FrequencyV.reserve(ESTIMATED_RECS);
  std::vector < float > GNSSSpeedV; GNSSSpeedV.reserve(ESTIMATED_RECS);
  std::vector < float > WaterTemperatureV; WaterTemperatureV.reserve(ESTIMATED_RECS);
  std::vector < float > WaterSpeedV; WaterSpeedV.reserve(ESTIMATED_RECS);
  std::vector < float > GNSSHeadingV; GNSSHeadingV.reserve(ESTIMATED_RECS);
  std::vector < float > GNSSAltitudeV; GNSSAltitudeV.reserve(ESTIMATED_RECS);
  std::vector < float > MagneticHeadingV; MagneticHeadingV.reserve(ESTIMATED_RECS);
  std::vector < long > MillisecondsV; MillisecondsV.reserve(ESTIMATED_RECS);
  std::vector < long > XLowranceV; XLowranceV.reserve(ESTIMATED_RECS);
  std::vector < long > YLowranceV; YLowranceV.reserve(ESTIMATED_RECS);
  std::vector < long > timeoffsetV; timeoffsetV.reserve(ESTIMATED_RECS);
  std::vector < bool > headingValidV; headingValidV.reserve(ESTIMATED_RECS);
  std::vector < bool > altitudeValidV; altitudeValidV.reserve(ESTIMATED_RECS);
  std::vector < bool > gpsSpeedValidV; gpsSpeedValidV.reserve(ESTIMATED_RECS);
  std::vector < bool > waterTempValidV; waterTempValidV.reserve(ESTIMATED_RECS);
  std::vector < bool > positionValidV; positionValidV.reserve(ESTIMATED_RECS);
  std::vector < bool > waterSpeedValidV; waterSpeedValidV.reserve(ESTIMATED_RECS);
  std::vector < bool > trackValidV; trackValidV.reserve(ESTIMATED_RECS);
  
  DataFrame out;
  
  ::std::ifstream in;
  in.rdbuf()->pubsetbuf(buffer, sizeof buffer);
  in.open(full_path, ::std::ifstream::in |::std::ios::binary);
  
  uint16_t format;
  in.read((char *)&format, sizeof(format));
  
  uint16_t version;
  in.read((char *)&version, sizeof(version));
  
  uint16_t blockSize;
  in.read((char *)&blockSize, sizeof(blockSize));
  
  in.seekg(8); // start of records
  
  int i;
  
  while (!(in.tellg() == -1)) {
    
    std::streampos recStart = in.tellg();
    
    uint32_t PositionOfFirstByte;
    in.seekg(recStart); in.seekg(0, std::ios_base::cur);
    in.read((char *)&PositionOfFirstByte, sizeof(PositionOfFirstByte));
    
    PositionOfFirstByteV.push_back(PositionOfFirstByte);
    
    uint16_t TotalLength;
    in.seekg(recStart); in.seekg(28, std::ios_base::cur);
    in.read((char *)&TotalLength, sizeof(TotalLength));
    
    TotalLengthV.push_back(TotalLength);
    
    uint16_t SurveyType;
    in.seekg(recStart); in.seekg(32, std::ios_base::cur);
    in.read((char *)&SurveyType, sizeof(SurveyType));
    
    SurveyTypeV.push_back(SurveyType);
    
    //uint16_t packetSize;
    //in.seekg(recStart); in.seekg(34, std::ios_base::cur);
    //in.read((char *)&packetSize, sizeof(packetSize));
    
    //packetSizeV.push_back(packetSize);
    
    float MinRange, MaxRange;
    in.seekg(recStart); in.seekg(40, std::ios_base::cur);
    in.read((char *)&MinRange, sizeof(MinRange));
    in.read((char *)&MaxRange, sizeof(MaxRange));
    
    MinRangeV.push_back(MinRange);
    MaxRangeV.push_back(MaxRange);
    
    //uint8_t Frequency;
    //in.seekg(recStart); in.seekg(53, std::ios_base::cur);
    //in.read((char *)&Frequency, sizeof(Frequency));
    
    float WaterDepth;
    in.seekg(recStart); in.seekg(64, std::ios_base::cur);
    in.read((char *)&WaterDepth, sizeof(WaterDepth));

    WaterDepthV.push_back(WaterDepth);

    float GNSSSpeed, WaterTemperature, WaterSpeed, GNSSHeading, GNSSAltitude, MagneticHeading;
    uint32_t XLowrance, YLowrance;
    std::bitset<16> flags;
    in.seekg(recStart); in.seekg(100, std::ios_base::cur);
    in.read((char *)&GNSSSpeed, sizeof(GNSSSpeed));
    in.read((char *)&WaterTemperature, sizeof(WaterTemperature));
    in.read((char *)&XLowrance, sizeof(XLowrance));
    in.read((char *)&YLowrance, sizeof(YLowrance));
    in.read((char *)&WaterSpeed, sizeof(WaterSpeed));
    in.read((char *)&GNSSHeading, sizeof(GNSSHeading));
    in.read((char *)&GNSSAltitude, sizeof(GNSSAltitude));
    in.read((char *)&MagneticHeading, sizeof(MagneticHeading));
    in.read((char *)&flags, sizeof(flags));
    
    GNSSSpeedV.push_back(GNSSSpeed);
    WaterTemperatureV.push_back(WaterTemperature);
    WaterSpeedV.push_back(WaterSpeed);
    GNSSHeadingV.push_back(GNSSHeading);
    GNSSAltitudeV.push_back(GNSSAltitude);
    MagneticHeadingV.push_back(MagneticHeading);
    XLowranceV.push_back(XLowrance);
    YLowranceV.push_back(YLowrance);
    
    headingValidV.push_back(flags.test(0));
    altitudeValidV.push_back(flags.test(1));
    gpsSpeedValidV.push_back(flags.test(9));
    waterTempValidV.push_back(flags.test(10));
    positionValidV.push_back(flags.test(12));
    waterSpeedValidV.push_back(flags.test(14));
    trackValidV.push_back(flags.test(15));
    
    uint32_t Milliseconds;
    in.seekg(recStart); in.seekg(140, std::ios_base::cur);
    in.read((char *)&Milliseconds, sizeof(Milliseconds));
    
    MillisecondsV.push_back(Milliseconds);
    
    in.seekg(recStart); 
    //in.seekg(144, std::ios_base::cur);
    in.seekg(TotalLength, std::ios_base::cur);
    
    if (i % 10000 == 0)
      checkUserInterrupt();
    
    i++;
    
  }
  
  PositionOfFirstByteV.resize(PositionOfFirstByteV.size()-1);
  TotalLengthV.resize(TotalLengthV.size()-1);
  SurveyTypeV.resize(SurveyTypeV.size()-1);
  MinRangeV.resize(MinRangeV.size()-1);
  MaxRangeV.resize(MaxRangeV.size()-1);
  WaterDepthV.resize(WaterDepthV.size()-1);
  //FrequencyV.resize(FrequencyV.size()-1);
  GNSSSpeedV.resize(GNSSSpeedV.size()-1);
  WaterTemperatureV.resize(WaterTemperatureV.size()-1);
  WaterSpeedV.resize(WaterSpeedV.size()-1);
  GNSSHeadingV.resize(GNSSHeadingV.size()-1);
  GNSSAltitudeV.resize(GNSSAltitudeV.size()-1);
  MagneticHeadingV.resize(MagneticHeadingV.size()-1);
  XLowranceV.resize(XLowranceV.size()-1);
  YLowranceV.resize(YLowranceV.size()-1);
  MillisecondsV.resize(MillisecondsV.size()-1);
  headingValidV.resize(headingValidV.size()-1);
  altitudeValidV.resize(altitudeValidV.size()-1);
  gpsSpeedValidV.resize(gpsSpeedValidV.size()-1);
  waterTempValidV.resize(waterTempValidV.size()-1);
  positionValidV.resize(positionValidV.size()-1);
  waterSpeedValidV.resize(waterSpeedValidV.size()-1);
  trackValidV.resize(trackValidV.size()-1);
  
  out = DataFrame::create(
    _["PositionOfFirstByte"] = PositionOfFirstByteV,
    _["TotalLength"] = TotalLengthV,
    _["SurveyType"] = SurveyTypeV,
    _["MinRange"] = MinRangeV,
    _["MaxRange"] = MaxRangeV,
    //_["Frequency"] = FrequencyV,
    _["WaterDepth"] = WaterDepthV,
    _["GNSSSpeed"] = GNSSSpeedV,
    _["WaterTemperature"] = WaterTemperatureV,
    _["WaterSpeed"] = WaterSpeedV,
    _["GNSSHeading"] = GNSSHeadingV,
    _["GNSSAltitude"] = GNSSAltitudeV,
    _["MagneticHeading"] = MagneticHeadingV,
    _["XLowrance"] = XLowranceV,
    _["YLowrance"] = YLowranceV,
    _["Milliseconds"] = MillisecondsV,
    _["valid"] = List::create(
      _["heading"] = headingValidV,
      _["altitude"] = altitudeValidV,
      _["gpsSpeed"] = gpsSpeedValidV,
      _["waterTemp"] = waterTempValidV,
      _["position"] = positionValidV,
      _["waterSpeed"] = waterSpeedValidV,
      _["track"] = trackValidV
    ),
    _["stringsAsFactors"] = false
  );
  
  out.attr("class") = CharacterVector::create("data.frame");
  out.attr("format") = CharacterVector::create(std::to_string(format));
  out.attr("version") = CharacterVector::create(std::to_string(version));
  out.attr("blocksize") = CharacterVector::create(std::to_string(blockSize));
  
  return(out);
  
}