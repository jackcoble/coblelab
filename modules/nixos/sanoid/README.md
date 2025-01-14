# sanoid

The [sanoid](https://github.com/jimsalterjrs/sanoid) module takes care of snapshotting my ZFS datasets. Sanoid is great as it is policy driven, and also offers a tool to sync snapshots should I need it in the future.

## Snapshot Lifetime

My backup strategy involves storing multiple generations of snapshots over a period of time. The goal being to minimise the amount of data loss if something catastrophic was to happen. I have devised the following snapshot lifetime policy.

| Snapshot Frequency | Retention Period         | Purpose                                                                       |
| ------------------ | ------------------------ | ----------------------------------------------------------------------------- |
| Every 15 minutes   | 6 hours (90 snapshots)   | Capture frequent changes to minimise data loss for highly active files.       |
| Hourly             | 24 hours (24 snapshots)  | Frequent recovery points for the majority of data.                            |
| Daily              | 14 days (14 snapshots)   | Covers scenarios where I may not notice data missing for a few days.          |
| Weekly             | 4 weeks (4 snapshots)    | Provides a safety net for if I need to recover less frequently accessed data. |
| Every 4 weeks      | 12 months (12 snapshots) | Provides a good recovery point for older data.                                |
| Yearly             | 3 years (3 snapshots)    | Primarily for long-term storage/archival.                                     |
