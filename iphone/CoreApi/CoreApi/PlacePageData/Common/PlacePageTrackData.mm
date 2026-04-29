#import "ElevationProfileData+Core.h"
#import "PlacePageTrackData+Core.h"
#import "PlacePageTrackSelectionData+Core.h"
#import "TrackInfo+Core.h"

@interface PlacePageTrackData ()

@property(nonatomic, readwrite) double activePointDistance;
@property(nonatomic, readwrite) NSArray<PlacePageTrackSelectionData *> * trackSelectionCandidates;

@end

@implementation PlacePageTrackData

- (instancetype)initWithTrackInfo:(TrackInfo *)trackInfo
                    elevationInfo:(ElevationProfileData * _Nullable)elevationInfo
             onActivePointChanged:(MWMVoidBlock)onActivePointChangedHandler
{
  self = [super init];
  if (self)
  {
    _trackInfo = trackInfo;
    _elevationProfileData = elevationInfo;
    _onActivePointChangedHandler = onActivePointChangedHandler;
    _trackSelectionCandidates = @[];
  }
  return self;
}

- (void)updateActivePointDistance:(double)distance
{
  self.activePointDistance = distance;
  if (self.onActivePointChangedHandler)
    self.onActivePointChangedHandler();
}

@end

@implementation PlacePageTrackData (Core)

- (instancetype)initWithRawData:(place_page::Info const &)rawData
           onActivePointChanged:(MWMVoidBlock)onActivePointChangedHandler
{
  self = [super init];
  if (self)
  {
    auto const trackPtr = GetFramework().GetBookmarkManager().GetTrack(rawData.GetTrackId());
    auto const & track = *trackPtr;
    auto const & bm = GetFramework().GetBookmarkManager();

    _trackId = track.GetData().m_id;

    auto const & groupId = track.GetGroupId();
    if (groupId && bm.HasBmCategory(groupId))
    {
      _groupId = groupId;
      _trackCategory = [NSString stringWithCString:bm.GetCategoryName(groupId).c_str() encoding:NSUTF8StringEncoding];
    }

    auto const color = track.GetColor(0);
    _color = [UIColor colorWithRed:color.GetRedF() green:color.GetGreenF() blue:color.GetBlueF() alpha:1.f];

    _trackDescription = [NSString stringWithCString:track.GetDescription().c_str() encoding:NSUTF8StringEncoding];
    _trackInfo = [[TrackInfo alloc] initWithTrackStatistics:track.GetStatistics()];
    _activePointDistance = bm.GetElevationActivePoint(_trackId);
    _myPositionDistance = bm.GetElevationMyPosition(_trackId);
    _onActivePointChangedHandler = onActivePointChangedHandler;
    NSMutableArray<PlacePageTrackSelectionData *> * trackSelectionCandidates = [NSMutableArray array];
    //    auto const selectedCandidateIndex = rawData.GetSelectedTrackSelectionCandidateIndex();
    auto const & selectionInfos = rawData.GetTrackCandidates();
    for (size_t candidateIndex = 0; candidateIndex < selectionInfos.size(); ++candidateIndex)
    {
      auto const & selectionInfo = selectionInfos[candidateIndex];
      auto selectionColor = selectionInfo.m_color;
      auto * color = [UIColor colorWithRed:selectionColor.GetRedF()
                                     green:selectionColor.GetGreenF()
                                      blue:selectionColor.GetBlueF()
                                     alpha:1.f];
      // TODO: fix isSelected
      auto * selectionData = [[PlacePageTrackSelectionData alloc] initWithTrackId:selectionInfo.m_trackId
                                                                       relationId:selectionInfo.m_featureId
                                                                            title:@(selectionInfo.m_title.c_str())
                                                                            color:color
                                                                       isSelected:NO];
      [trackSelectionCandidates addObject:selectionData];
    }
    _trackSelectionCandidates = trackSelectionCandidates;

    auto const * elevationInfo = track.GetElevationInfo();
    if (elevationInfo)
      _elevationProfileData = [[ElevationProfileData alloc] initWithTrackId:_trackId elevationInfo:*elevationInfo];
  }
  return self;
}

@end
