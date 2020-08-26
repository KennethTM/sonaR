#include <Rcpp.h>

#include <iostream>
#include <fstream>
#include <bitset>

using namespace Rcpp;

#define MAX_BUFFER_SIZE (1024 * 1000)
#define ESTIMATED_RECS 1000

// Function to read .sl2 files originally from the "arabia" R-package by Bob Rudis (<https://github.com/hrbrmstr/arabia>)
// Modified by Kenneth Thorø Martinsen

//' A "No Frills" Faster Version in C++
//'
//' No error checking (not even for file existence). No fancy names for channel/etc.
//' No unnesting of validity fields. BUT, it's wicked fast.
//'
//' @md
//' @param path
//' @return data frame (tibble)
//' @export
//' @examples
//' read_sl2_cpp(system.file("exdat", "example.sl2", package="arabia")))
// [[Rcpp::export]]

DataFrame read_sl2_cpp(std::string path) {
  
  std::string full_path = std::string(R_ExpandFileName(path.c_str()));
  
  char buffer[MAX_BUFFER_SIZE];
  std::vector < long > frameOffsetV; frameOffsetV.reserve(ESTIMATED_RECS);
  std::vector < long > blockSizeV; blockSizeV.reserve(ESTIMATED_RECS);
  std::vector < long > channelV; channelV.reserve(ESTIMATED_RECS);
  std::vector < long > packetSizeV; packetSizeV.reserve(ESTIMATED_RECS);
  std::vector < float > upperLimitV; upperLimitV.reserve(ESTIMATED_RECS);
  std::vector < float > lowerLimitV; lowerLimitV.reserve(ESTIMATED_RECS);
  std::vector < float > waterDepthV; waterDepthV.reserve(ESTIMATED_RECS);
  std::vector < float > keelDepthV; keelDepthV.reserve(ESTIMATED_RECS);
  std::vector < float > speedGpsV; speedGpsV.reserve(ESTIMATED_RECS);
  std::vector < float > temperatureV; temperatureV.reserve(ESTIMATED_RECS);
  std::vector < float > speedWaterV; speedWaterV.reserve(ESTIMATED_RECS);
  std::vector < float > trackV; trackV.reserve(ESTIMATED_RECS);
  std::vector < float > altitudeV; altitudeV.reserve(ESTIMATED_RECS);
  std::vector < float > headingV; headingV.reserve(ESTIMATED_RECS);
  std::vector < float > timeOffsetV; timeOffsetV.reserve(ESTIMATED_RECS);
  std::vector < long > lng_encV; lng_encV.reserve(ESTIMATED_RECS);
  std::vector < long > lat_encV; lat_encV.reserve(ESTIMATED_RECS);
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
  
  while (!(in.tellg() == -1)) {
    
    std::streampos recStart = in.tellg();
    
    uint32_t frameOffset;
    in.seekg(recStart); in.seekg(0, std::ios_base::cur);
    in.read((char *)&frameOffset, sizeof(frameOffset));
    
    frameOffsetV.push_back(frameOffset);
    
    uint16_t blockSize;
    in.seekg(recStart); in.seekg(28, std::ios_base::cur);
    in.read((char *)&blockSize, sizeof(blockSize));
    
    blockSizeV.push_back(blockSize);
    
    uint16_t channel;
    in.seekg(recStart); in.seekg(32, std::ios_base::cur);
    in.read((char *)&channel, sizeof(channel));
    
    channelV.push_back(channel);
    
    uint16_t packetSize;
    in.seekg(recStart); in.seekg(34, std::ios_base::cur);
    in.read((char *)&packetSize, sizeof(packetSize));
    
    packetSizeV.push_back(packetSize);
    
    float upperLimit, lowerLimit;
    in.seekg(recStart); in.seekg(40, std::ios_base::cur);
    in.read((char *)&upperLimit, sizeof(upperLimit));
    in.read((char *)&lowerLimit, sizeof(lowerLimit));
    
    upperLimitV.push_back(upperLimit);
    lowerLimitV.push_back(lowerLimit);
    
    float waterDepth, keelDepth;
    in.seekg(recStart); in.seekg(64, std::ios_base::cur);
    in.read((char *)&waterDepth, sizeof(waterDepth));
    in.read((char *)&keelDepth, sizeof(keelDepth));
    
    waterDepthV.push_back(waterDepth);
    keelDepthV.push_back(keelDepth);
    
    float speedGps, temperature, speedWater, track, altitude, heading;
    uint32_t lng_eng, lat_enc;
    std::bitset<16> flags;
    in.seekg(recStart); in.seekg(100, std::ios_base::cur);
    in.read((char *)&speedGps, sizeof(speedGps));
    in.read((char *)&temperature, sizeof(temperature));
    in.read((char *)&lng_eng, sizeof(lng_eng));
    in.read((char *)&lat_enc, sizeof(lat_enc));
    in.read((char *)&speedWater, sizeof(speedWater));
    in.read((char *)&track, sizeof(track));
    in.read((char *)&altitude, sizeof(altitude));
    in.read((char *)&heading, sizeof(heading));
    in.read((char *)&flags, sizeof(flags));
    
    speedGpsV.push_back(speedGps);
    temperatureV.push_back(temperature);
    speedWaterV.push_back(speedWater);
    trackV.push_back(track);
    altitudeV.push_back(altitude);
    headingV.push_back(heading);
    lng_encV.push_back(lng_eng);
    lat_encV.push_back(lat_enc);
    
    headingValidV.push_back(flags.test(0));
    altitudeValidV.push_back(flags.test(1));
    gpsSpeedValidV.push_back(flags.test(9));
    waterTempValidV.push_back(flags.test(10));
    positionValidV.push_back(flags.test(12));
    waterSpeedValidV.push_back(flags.test(14));
    trackValidV.push_back(flags.test(15));
    
    uint32_t timeOffset;
    in.seekg(recStart); in.seekg(140, std::ios_base::cur);
    in.read((char *)&timeOffset, sizeof(timeOffset));
    
    timeOffsetV.push_back(timeOffset);
    
    in.seekg(recStart); in.seekg(144, std::ios_base::cur);
    in.seekg(packetSize, std::ios_base::cur);
    
  }
  
  frameOffsetV.resize(frameOffsetV.size()-1);
  blockSizeV.resize(blockSizeV.size()-1);
  packetSizeV.resize(packetSizeV.size()-1);
  channelV.resize(channelV.size()-1);
  upperLimitV.resize(upperLimitV.size()-1);
  lowerLimitV.resize(lowerLimitV.size()-1);
  waterDepthV.resize(waterDepthV.size()-1);
  keelDepthV.resize(keelDepthV.size()-1);
  speedGpsV.resize(speedGpsV.size()-1);
  temperatureV.resize(temperatureV.size()-1);
  speedWaterV.resize(speedWaterV.size()-1);
  trackV.resize(trackV.size()-1);
  altitudeV.resize(altitudeV.size()-1);
  headingV.resize(headingV.size()-1);
  lng_encV.resize(lng_encV.size()-1);
  lat_encV.resize(lat_encV.size()-1);
  timeOffsetV.resize(timeOffsetV.size()-1);
  headingValidV.resize(headingValidV.size()-1);
  altitudeValidV.resize(altitudeValidV.size()-1);
  gpsSpeedValidV.resize(gpsSpeedValidV.size()-1);
  waterTempValidV.resize(waterTempValidV.size()-1);
  positionValidV.resize(positionValidV.size()-1);
  waterSpeedValidV.resize(waterSpeedValidV.size()-1);
  trackValidV.resize(trackValidV.size()-1);
  
  out = DataFrame::create(
    _["frameOffset"] = frameOffsetV,
    _["blockSize"] = blockSizeV,
    _["packetSize"] = packetSizeV,
    _["channel"] = channelV,
    _["upperLimit"] = upperLimitV,
    _["lowerLimit"] = lowerLimitV,
    _["waterDepth"] = waterDepthV,
    _["keelDepth"] = keelDepthV,
    _["speedGps"] = speedGpsV,
    _["temperature"] = temperatureV,
    _["speedWater"] = speedWaterV,
    _["track"] = trackV,
    _["altitude"] = altitudeV,
    _["heading"] = headingV,
    _["lng_enc"] = lng_encV,
    _["lat_enc"] = lat_encV,
    _["timeOffset"] = timeOffsetV,
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